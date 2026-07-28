import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Persists auth tokens in the platform secure storage (Keychain on iOS,
/// Keystore-backed EncryptedSharedPreferences on Android) instead of plain
/// SharedPreferences, since these are long-lived bearer credentials.
class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  static const _refreshTokenKey = '${AppConstants.cachedTokenKey}_refresh';

  /// Save access token to secure storage
  Future<bool> saveToken(String token) async {
    await _storage.write(key: AppConstants.cachedTokenKey, value: token);
    return true;
  }

  /// Get access token from secure storage
  Future<String?> getToken() {
    return _storage.read(key: AppConstants.cachedTokenKey);
  }

  /// Save refresh token to secure storage
  Future<bool> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    return true;
  }

  /// Get refresh token from secure storage
  Future<String?> getRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Delete access token from secure storage
  Future<bool> deleteToken() async {
    await _storage.delete(key: AppConstants.cachedTokenKey);
    return true;
  }

  /// Delete refresh token from secure storage
  Future<bool> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
    return true;
  }

  /// Delete both tokens from secure storage
  Future<bool> deleteAllTokens() async {
    await _storage.delete(key: AppConstants.cachedTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    return true;
  }

  /// Check if access token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
