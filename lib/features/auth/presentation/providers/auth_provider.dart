import 'package:flutter/material.dart';
import '../../../../shared/enums/app_status.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetProfileUseCase getProfileUseCase;
  final LogoutUseCase logoutUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getProfileUseCase,
    required this.logoutUseCase,
  });

  // State Variables
  UserEntity? _currentUser;
  AppStatus _status = AppStatus.initial;
  String? _errorMessage;

  // Getters
  UserEntity? get currentUser => _currentUser;
  AppStatus get status => _status;
  String? get errorMessage => _errorMessage;
  
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _status == AppStatus.loading;

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

  /// Perform user Login
  Future<bool> login(String email, String password) async {
    _status = AppStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await loginUseCase(email, password);
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
