import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> getProfile();

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> fields);

  Future<Map<String, dynamic>> uploadAvatar(File imageFile);

  Future<Map<String, dynamic>> deleteAvatar();

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> deleteAccount(String password);

  /// Returns `{secret, otpauthUrl}` for the authenticator app.
  Future<Map<String, dynamic>> setupTwoFactor();

  Future<void> enableTwoFactor(String code);

  Future<void> disableTwoFactor(String code);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this.dioClient);

  final DioClient dioClient;

  Map<String, dynamic> _extractUser(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map && data['user'] is Map) {
        return Map<String, dynamic>.from(data['user'] as Map);
      }
    }
    throw const ServerException('Invalid profile response from server');
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dioClient.get(ApiConstants.profileMe);
      return _extractUser(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> fields,
  ) async {
    try {
      final response = await dioClient.patch(ApiConstants.profileMe, data: fields);
      return _extractUser(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> uploadAvatar(File imageFile) async {
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
      return _extractUser(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> deleteAvatar() async {
    try {
      final response = await dioClient.delete(ApiConstants.profilePicture);
      return _extractUser(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Map<String, dynamic> _extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    throw const ServerException('Invalid response from server');
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await dioClient.patch(
        ApiConstants.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      await dioClient.delete(ApiConstants.profileMe, data: {'password': password});
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> setupTwoFactor() async {
    try {
      final response = await dioClient.post(ApiConstants.twoFactorSetup);
      return _extractData(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> enableTwoFactor(String code) async {
    try {
      await dioClient.post(ApiConstants.twoFactorEnable, data: {'code': code});
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> disableTwoFactor(String code) async {
    try {
      await dioClient.post(ApiConstants.twoFactorDisable, data: {'code': code});
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
