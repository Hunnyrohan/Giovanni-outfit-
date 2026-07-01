import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<Map<String, dynamic>> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Invalid login response from server');
    } on DioException catch (dioError) {
      // Fallback dummy database logic for testing when no server is running
      if (dioError.type == DioExceptionType.connectionError || 
          dioError.type == DioExceptionType.connectionTimeout) {
        return _mockLoginResponse(email);
      }
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      if (response.data != null && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Invalid registration response from server');
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionError || 
          dioError.type == DioExceptionType.connectionTimeout) {
        return _mockRegisterResponse(name, email);
      }
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
        // The API returns the profile directly or inside a user block
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('user')) {
          return data['user'] as Map<String, dynamic>;
        }
        return data;
      }
      throw const ServerException('Invalid profile response from server');
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionError || 
          dioError.type == DioExceptionType.connectionTimeout) {
        return _mockProfileResponse();
      }
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // --- Fallback Mock Database Helpers ---

  Future<Map<String, dynamic>> _mockLoginResponse(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network lag
    if (email.contains('error')) {
      throw const AuthException('Invalid email or password.');
    }
    return {
      'token': 'mock_jwt_token_stylesense_ai',
      'user': {
        'id': 'user_01_mock',
        'name': 'Sarah Jenkins',
        'email': email,
        'profilePicture': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      }
    };
  }

  Future<Map<String, dynamic>> _mockRegisterResponse(String name, String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'token': 'mock_jwt_token_stylesense_ai',
      'user': {
        'id': 'user_01_mock',
        'name': name,
        'email': email,
        'profilePicture': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      }
    };
  }

  Future<Map<String, dynamic>> _mockProfileResponse() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': 'user_01_mock',
      'name': 'Sarah Jenkins',
      'email': 'sarah.stylesense@example.com',
      'profilePicture': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    };
  }
}
