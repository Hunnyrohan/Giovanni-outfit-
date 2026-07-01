import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class TokenStorage {
  final SharedPreferences _prefs;

  TokenStorage(this._prefs);

  /// Save token to local storage
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(AppConstants.cachedTokenKey, token);
  }

  /// Get token from local storage
  String? getToken() {
    return _prefs.getString(AppConstants.cachedTokenKey);
  }

  /// Delete token from local storage
  Future<bool> deleteToken() async {
    return await _prefs.remove(AppConstants.cachedTokenKey);
  }

  /// Check if token exists
  bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}
