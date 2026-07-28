import '../../../../core/errors/failure.dart';
import '../entities/chat_message_result.dart';
import '../entities/conversation_history.dart';

abstract class AiStylistRepository {
  Future<Either<Failure, ChatMessageResult>> sendMessage({
    String? chatId,
    required String message,
  });

  Future<Either<Failure, List<ConversationHistory>>> getHistory();

  Future<Either<Failure, ConversationHistory>> getHistoryDetail(String chatId);

  Future<Either<Failure, void>> deleteConversation(String chatId);

  Future<Either<Failure, void>> deleteAllConversations();
}
