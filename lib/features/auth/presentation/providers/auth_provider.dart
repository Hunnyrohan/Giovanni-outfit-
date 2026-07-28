import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/errors/failure.dart';
import '../../../../shared/enums/app_status.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_profile_picture_usecase.dart';
import '../../domain/usecases/verify_two_factor_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final GoogleLoginUseCase googleLoginUseCase;
  final RegisterUseCase registerUseCase;
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfilePictureUseCase updateProfilePictureUseCase;
  final LogoutUseCase logoutUseCase;
  final VerifyTwoFactorUseCase verifyTwoFactorUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.googleLoginUseCase,
    required this.registerUseCase,
    required this.getProfileUseCase,
    required this.updateProfilePictureUseCase,
    required this.logoutUseCase,
    required this.verifyTwoFactorUseCase,
  });

  // State Variables
  UserEntity? _currentUser;
  AppStatus _status = AppStatus.initial;
  String? _errorMessage;
  bool _isUpdatingPicture = false;
  String? _pendingTwoFactorToken;

  // Getters
  UserEntity? get currentUser => _currentUser;
  AppStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _status == AppStatus.loading;
  bool get isUpdatingPicture => _isUpdatingPicture;

  /// True when the password step of a login succeeded but the account has
  /// 2FA enabled - the UI must collect the 6-digit code next.
  bool get requiresTwoFactor => _pendingTwoFactorToken != null;

  /// Check if the user is already authenticated on app startup
  Future<bool> checkAuthStatus() async {
    _status = AppStatus.loading;
    notifyListeners();

    final result = await getProfileUseCase();
    return result.fold(
      (failure) {
        _currentUser = null;
        _status = AppStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _status = AppStatus.success;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Perform user Login.
  /// Returns true when fully signed in. When it returns false, check
  /// [requiresTwoFactor]: if set, the password was correct and the UI must
  /// collect a 6-digit authenticator code via [verifyTwoFactor].
  Future<bool> login(String email, String password) async {
    _status = AppStatus.loading;
    _errorMessage = null;
    _pendingTwoFactorToken = null;
    notifyListeners();

    final result = await loginUseCase(email, password);
    return result.fold(
      (failure) {
        if (failure is TwoFactorRequiredFailure) {
          _pendingTwoFactorToken = failure.twoFactorToken;
          _status = AppStatus.initial;
          _errorMessage = null;
          notifyListeners();
          return false;
        }
        _status = AppStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _status = AppStatus.success;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Completes a two-step (2FA) login with the authenticator code.
  Future<bool> verifyTwoFactor(String code) async {
    final token = _pendingTwoFactorToken;
    if (token == null) {
      _errorMessage = 'No two-factor login in progress. Please log in again.';
      notifyListeners();
      return false;
    }

    _status = AppStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await verifyTwoFactorUseCase(token, code);
    return result.fold(
      (failure) {
        _status = AppStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _pendingTwoFactorToken = null;
        _currentUser = user;
        _status = AppStatus.success;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Abandons a pending two-factor login (e.g. user backs out of the code screen).
  void cancelTwoFactor() {
    _pendingTwoFactorToken = null;
    _status = AppStatus.initial;
    notifyListeners();
  }

  /// Perform Google Login
  Future<bool> googleLogin() async {
    _status = AppStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await googleLoginUseCase();
    return result.fold(
      (failure) {
        _status = AppStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _status = AppStatus.success;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Perform user Registration
  Future<bool> register(String name, String email, String password) async {
    _status = AppStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await registerUseCase(name, email, password);
    return result.fold(
      (failure) {
        _status = AppStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _status = AppStatus.success;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Upload and set a new profile picture for the current user
  Future<bool> updateProfilePicture(File imageFile) async {
    _isUpdatingPicture = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateProfilePictureUseCase(imageFile);
    return result.fold(
      (failure) {
        _isUpdatingPicture = false;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _isUpdatingPicture = false;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Perform user Logout
  Future<bool> logout() async {
    _status = AppStatus.loading;
    notifyListeners();

    final result = await logoutUseCase();
    return result.fold(
      (failure) {
        _status = AppStatus.failure;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _currentUser = null;
        _status = AppStatus.initial;
        _errorMessage = null;
        notifyListeners();
        return true;
      },
    );
  }

  /// Clear current errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
