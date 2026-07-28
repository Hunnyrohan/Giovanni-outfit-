import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/chat_message_result.dart';
import '../../domain/entities/conversation_history.dart';
import '../../domain/repositories/ai_stylist_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../models/conversation_history_model.dart';
import '../models/message_model.dart';

class AiStylistRepositoryImpl implements AiStylistRepository {
  final AiRemoteDataSource remoteDataSource;

  AiStylistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatMessageResult>> sendMessage({
    String? chatId,
    required String message,
  }) async {
    try {
      final data = await remoteDataSource.sendMessage(chatId: chatId, message: message);

      final result = ChatMessageResult(
        chat: ConversationHistoryModel.fromJson(data['chat'] as Map<String, dynamic>),
        userMessage: MessageModel.fromJson(data['userMessage'] as Map<String, dynamic>),
        aiMessage: MessageModel.fromJson(data['aiMessage'] as Map<String, dynamic>),
      );

      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ConversationHistory>>> getHistory() async {
    try {
      final chats = await remoteDataSource.getHistory();

      return Right(
        chats
            .map((chat) => ConversationHistoryModel.fromJson(chat as Map<String, dynamic>))
            .toList(),
      );
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ConversationHistory>> getHistoryDetail(String chatId) async {
    try {
      final data = await remoteDataSource.getHistoryDetail(chatId);

      return Right(ConversationHistoryModel.fromJson(data));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String chatId) async {
    try {
      await remoteDataSource.deleteConversation(chatId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllConversations() async {
    try {
      await remoteDataSource.deleteAllConversations();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
