import 'dart:io';

import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> verifyTwoFactor(String twoFactorToken, String code);
  Future<Map<String, dynamic>> googleLogin();
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  );
  Future<Map<String, dynamic>> getProfile();
  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl(this.dioClient, {GoogleSignIn? googleSignIn})
    : googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: const ['email', 'profile'],
            serverClientId: ApiConstants.googleClientId,
          );

  /// Unwraps the standard `{success, message, data}` envelope and returns
  /// the `data` object, which contains `user`, `token`, `refreshToken`, `tokens`.
  Map<String, dynamic> _unwrapAuthEnvelope(Response response) {
    if (response.data != null && response.data is Map<String, dynamic>) {
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    throw const ServerException('Invalid authentication response from server');
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return _unwrapAuthEnvelope(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> verifyTwoFactor(String twoFactorToken, String code) async {
    try {
      final response = await dioClient.post(
        ApiConstants.twoFactorVerify,
        data: {'twoFactorToken': twoFactorToken, 'code': code},
      );
      return _unwrapAuthEnvelope(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> googleLogin() async {
    try {
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Google did not return an ID token');
      }

      final response = await dioClient.post(
        ApiConstants.googleLogin,
        data: {'idToken': idToken},
      );

      return _unwrapAuthEnvelope(response);
    } on PlatformException {
      throw AuthException(
        'Google sign-in failed on Android. Check that your Google OAuth Android client uses package name com.rohan.outfit_ai_app and SHA-1 03:19:20:ED:0E:73:38:DE:29:DA:99:69:A4:61:86:4F:8D:CF:0A:30, and that the web client ID matches the backend.',
      );
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      return _unwrapAuthEnvelope(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dioClient.get(ApiConstants.profile);
      if (response.data != null && response.data is Map<String, dynamic>) {
        final envelope = response.data as Map<String, dynamic>;
        final data = envelope['data'];
        if (data is Map && data['user'] is Map) {
          return (data['user'] as Map).cast<String, dynamic>();
        }
      }
      throw const ServerException('Invalid profile response from server');
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> uploadProfilePicture(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.uri.pathSegments.last,
        ),
      });

      final response = await dioClient.post(
        ApiConstants.profilePicture,
        data: formData,
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final nested = data['data'];
        if (nested is Map && nested['user'] is Map) {
          return nested['user'] as Map<String, dynamic>;
        }
        if (data['user'] is Map) {
          return data['user'] as Map<String, dynamic>;
        }
        return data;
      }
      throw const ServerException(
        'Invalid profile picture response from server',
      );
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post(ApiConstants.logout);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
