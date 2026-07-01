import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class ApiException {
  ApiException._();

  static Exception handleDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return const ServerException('Request to API server was cancelled');
      case DioExceptionType.connectionTimeout:
        return const ServerException('Connection timeout with API server');
      case DioExceptionType.receiveTimeout:
        return const ServerException('Receive timeout in connection with API server');
      case DioExceptionType.sendTimeout:
        return const ServerException('Send timeout in connection with API server');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection or server unreachable');
      case DioExceptionType.badResponse:
        final response = dioException.response;
        if (response != null) {
          final statusCode = response.statusCode;
          final dynamic data = response.data;
          
          String message = 'Unexpected response from server';
          
          if (data is Map && data.containsKey('message')) {
            message = data['message'].toString();
          } else if (data is Map && data.containsKey('error')) {
            message = data['error'].toString();
          } else {
            message = 'Server error ($statusCode)';
          }

          if (statusCode == 401 || statusCode == 403) {
            return AuthException(message);
          }
          return ServerException(message);
        }
        return const ServerException('Bad response from server');
      default:
        return const ServerException('Something went wrong. Please try again.');
    }
  }
}
