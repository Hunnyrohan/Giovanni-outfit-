import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';

abstract class AiRemoteDataSource {
  Future<Map<String, dynamic>> sendMessage({String? chatId, required String message});
  Future<List<dynamic>> getHistory();
  Future<Map<String, dynamic>> getHistoryDetail(String chatId);
  Future<void> deleteConversation(String chatId);
  Future<void> deleteAllConversations();
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final DioClient dioClient;

  AiRemoteDataSourceImpl(this.dioClient);

  Map<String, dynamic> _unwrapData(Response response) {
    if (response.data is Map<String, dynamic>) {
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    throw const ServerException('Invalid response from server');
  }

  @override
  Future<Map<String, dynamic>> sendMessage({String? chatId, required String message}) async {
    try {
      final response = await dioClient.post(
        ApiConstants.aiChat,
        data: {
          if (chatId != null) 'chatId': chatId,
          'message': message,
        },
      );
      return _unwrapData(response);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<dynamic>> getHistory() async {
    try {
      final response = await dioClient.get(ApiConstants.aiHistory);
      final data = _unwrapData(response);
      return data['chats'] as List<dynamic>? ?? [];
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getHistoryDetail(String chatId) async {
    try {
      final response = await dioClient.get(ApiConstants.aiHistoryItem(chatId));
      final data = _unwrapData(response);
      return data['chat'] as Map<String, dynamic>;
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteConversation(String chatId) async {
    try {
      await dioClient.delete(ApiConstants.aiHistoryItem(chatId));
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteAllConversations() async {
    try {
      await dioClient.delete(ApiConstants.aiHistory);
    } on DioException catch (dioError) {
      throw ApiException.handleDioError(dioError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
