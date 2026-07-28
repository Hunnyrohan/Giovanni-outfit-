import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> deleteRefreshToken();

  Future<void> cacheUser(UserModel userToCache);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorage tokenStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.tokenStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> saveToken(String token) async {
    try {
      final success = await tokenStorage.saveToken(token);
      if (!success)
        throw const CacheException('Failed to cache authentication token.');
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<String?> getToken() {
    return tokenStorage.getToken();
  }

  @override
  Future<void> deleteToken() async {
    try {
      final success = await tokenStorage.deleteToken();
      if (!success)
        throw const CacheException('Failed to remove cached token.');
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final success = await tokenStorage.saveRefreshToken(refreshToken);
      if (!success)
        throw const CacheException('Failed to cache refresh token.');
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<String?> getRefreshToken() {
    return tokenStorage.getRefreshToken();
  }

  @override
  Future<void> deleteRefreshToken() async {
    try {
      final success = await tokenStorage.deleteRefreshToken();
      if (!success)
        throw const CacheException('Failed to remove cached refresh token.');
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel userToCache) async {
    try {
      final userJson = jsonEncode(userToCache.toJson());
      final success = await sharedPreferences.setString(
        AppConstants.cachedUserKey,
        userJson,
      );
      if (!success)
        throw const CacheException('Failed to cache user profile info.');
    } catch (e) {
      throw const CacheException();
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    final userJson = sharedPreferences.getString(AppConstants.cachedUserKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (e) {
        throw const CacheException('Failed to parse cached user profile.');
      }
    } else {
      throw const CacheException('No cached user profile found.');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await deleteToken();
      await deleteRefreshToken();
      await sharedPreferences.remove(AppConstants.cachedUserKey);
    } catch (e) {
      throw const CacheException();
    }
  }
}
