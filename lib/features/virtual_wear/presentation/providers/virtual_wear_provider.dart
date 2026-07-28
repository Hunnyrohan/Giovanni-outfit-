import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../wardrobe/domain/entities/wardrobe_item_entity.dart';
import '../../domain/entities/try_on_job_entity.dart';
import '../../domain/usecases/create_try_on_usecase.dart';
import '../../domain/usecases/delete_try_on_usecase.dart';
import '../../domain/usecases/get_try_on_history_usecase.dart';
import '../../domain/usecases/get_try_on_status_usecase.dart';
import '../../domain/usecases/save_try_on_usecase.dart';

/// Exponential backoff schedule for polling job status, capped at 60s
/// between polls per the product spec (2, 2, 3, 5, 8, 13, 21, 34, 55, 60...).
const List<int> _pollBackoffSeconds = [2, 2, 3, 5, 8, 13, 21, 34, 55, 60];

/// Gives up and surfaces a client-side timeout rather than polling forever
/// if the AI Service never reaches a terminal state.
const Duration _maxPollDuration = Duration(minutes: 10);

class VirtualWearProvider extends ChangeNotifier {
  final CreateTryOnUseCase createTryOnUseCase;
  final GetTryOnStatusUseCase getTryOnStatusUseCase;
  final GetTryOnHistoryUseCase getTryOnHistoryUseCase;
  final DeleteTryOnUseCase deleteTryOnUseCase;
  final SaveTryOnUseCase saveTryOnUseCase;

  VirtualWearProvider({
    required this.createTryOnUseCase,
    required this.getTryOnStatusUseCase,
    required this.getTryOnHistoryUseCase,
    required this.deleteTryOnUseCase,
    required this.saveTryOnUseCase,
  });

  final ImagePicker _picker = ImagePicker();

  WardrobeItemEntity? _selectedItem;
  WardrobeItemEntity? get selectedItem => _selectedItem;

  File? _personImage;
  File? get personImage => _personImage;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  TryOnJobEntity? _currentJob;
  TryOnJobEntity? get currentJob => _currentJob;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TryOnJobEntity> _history = [];
  List<TryOnJobEntity> get history => List.unmodifiable(_history);
  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  bool get canGenerate => _selectedItem != null && _personImage != null && !_isSubmitting;

  void initialize(WardrobeItemEntity? item) {
    _selectedItem = item;
    _personImage = null;
    _currentJob = null;
    _errorMessage = null;
  }

  Future<void> pickPersonImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
      if (pickedFile != null) {
        _personImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Kicks off generation and polls until the job reaches a terminal state.
  /// The caller (screen) watches [currentJob] to know when to navigate to
  /// the result screen.
  Future<void> startTryOn() async {
    if (_selectedItem == null || _personImage == null) {
      _errorMessage = 'Select a photo and a garment before generating.';
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _currentJob = null;
    notifyListeners();

    final result = await createTryOnUseCase(
      wardrobeItemId: _selectedItem!.id,
      personImage: _personImage!,
    );

    final job = result.fold((failure) {
      _isSubmitting = false;
      _errorMessage = failure.message;
      notifyListeners();
      return null;
    }, (job) => job);

    if (job == null) return;

    _currentJob = job;
    notifyListeners();

    await _pollUntilTerminal(job.id);
  }

  Future<void> _pollUntilTerminal(String jobId) async {
    final deadline = DateTime.now().add(_maxPollDuration);
    var attempt = 0;

    while (DateTime.now().isBefore(deadline)) {
      final delaySeconds = _pollBackoffSeconds[attempt.clamp(0, _pollBackoffSeconds.length - 1)];
      await Future.delayed(Duration(seconds: delaySeconds));
      attempt += 1;

      final result = await getTryOnStatusUseCase(jobId);

      final shouldStop = result.fold((failure) {
        _isSubmitting = false;
        _errorMessage = failure.message;
        notifyListeners();
        return true;
      }, (job) {
        _currentJob = job;
        notifyListeners();
        return job.isTerminal;
      });

      if (shouldStop) {
        _isSubmitting = false;
        notifyListeners();
        return;
      }
    }

    _isSubmitting = false;
    _errorMessage = 'Generation is taking longer than expected. Please check history shortly.';
    notifyListeners();
  }

  Future<bool> deleteJob(String jobId) async {
    final result = await deleteTryOnUseCase(jobId);
    return result.fold((failure) {
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) {
      _history.removeWhere((job) => job.id == jobId);
      if (_currentJob?.id == jobId) {
        _currentJob = null;
      }
      notifyListeners();
      return true;
    });
  }

  Future<bool> saveCurrentJobToOutfits({String? title}) async {
    final job = _currentJob;
    if (job == null) return false;

    final result = await saveTryOnUseCase(job.id, title: title);
    return result.fold((failure) {
      _errorMessage = failure.message;
      notifyListeners();
      return false;
    }, (_) => true);
  }

  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    final result = await getTryOnHistoryUseCase();
    _isLoadingHistory = false;

    result.fold((failure) {
      _errorMessage = failure.message;
      notifyListeners();
    }, (jobs) {
      _history = jobs;
      notifyListeners();
    });
  }

  /// Resets state for "Generate Again" without losing the selected wardrobe item.
  void reset() {
    _personImage = null;
    _currentJob = null;
    _errorMessage = null;
    _isSubmitting = false;
    notifyListeners();
  }
}
