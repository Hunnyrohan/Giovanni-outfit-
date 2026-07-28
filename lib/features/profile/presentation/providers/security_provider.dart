import 'package:flutter/material.dart';

import '../../domain/entities/two_factor_setup_entity.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/disable_two_factor_usecase.dart';
import '../../domain/usecases/enable_two_factor_usecase.dart';
import '../../domain/usecases/get_two_factor_status_usecase.dart';
import '../../domain/usecases/setup_two_factor_usecase.dart';

/// Backs the Privacy & Security flows: password change, 2FA lifecycle and
/// account deletion. Each action returns true on success; on failure
/// [errorMessage] carries the human-readable reason for a snackbar.
class SecurityProvider extends ChangeNotifier {
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final GetTwoFactorStatusUseCase getTwoFactorStatusUseCase;
  final SetupTwoFactorUseCase setupTwoFactorUseCase;
  final EnableTwoFactorUseCase enableTwoFactorUseCase;
  final DisableTwoFactorUseCase disableTwoFactorUseCase;

  SecurityProvider({
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
    required this.getTwoFactorStatusUseCase,
    required this.setupTwoFactorUseCase,
    required this.enableTwoFactorUseCase,
    required this.disableTwoFactorUseCase,
  });

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// null until [loadTwoFactorStatus] completes the first time.
  bool? _twoFactorEnabled;
  bool? get twoFactorEnabled => _twoFactorEnabled;

  TwoFactorSetupEntity? _pendingSetup;
  TwoFactorSetupEntity? get pendingSetup => _pendingSetup;

  void _start() {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
  }

  bool _fail(String message) {
    _isBusy = false;
    _errorMessage = message;
    notifyListeners();
    return false;
  }

  bool _succeed() {
    _isBusy = false;
    notifyListeners();
    return true;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _start();
    final result = await changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return result.fold((failure) => _fail(failure.message), (_) => _succeed());
  }

  Future<bool> deleteAccount(String password) async {
    _start();
    final result = await deleteAccountUseCase(password: password);
    return result.fold((failure) => _fail(failure.message), (_) => _succeed());
  }

  Future<void> loadTwoFactorStatus() async {
    _start();
    final result = await getTwoFactorStatusUseCase();
    result.fold((failure) => _fail(failure.message), (enabled) {
      _twoFactorEnabled = enabled;
      return _succeed();
    });
  }

  Future<bool> setupTwoFactor() async {
    _start();
    final result = await setupTwoFactorUseCase();
    return result.fold((failure) => _fail(failure.message), (setup) {
      _pendingSetup = setup;
      return _succeed();
    });
  }

  Future<bool> enableTwoFactor(String code) async {
    _start();
    final result = await enableTwoFactorUseCase(code);
    return result.fold((failure) => _fail(failure.message), (_) {
      _twoFactorEnabled = true;
      _pendingSetup = null;
      return _succeed();
    });
  }

  Future<bool> disableTwoFactor(String code) async {
    _start();
    final result = await disableTwoFactorUseCase(code);
    return result.fold((failure) => _fail(failure.message), (_) {
      _twoFactorEnabled = false;
      return _succeed();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
