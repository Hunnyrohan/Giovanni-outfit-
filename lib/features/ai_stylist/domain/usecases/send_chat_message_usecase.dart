import '../../../../core/errors/failure.dart';
import '../entities/chat_message_result.dart';
import '../repositories/ai_stylist_repository.dart';

class SendChatMessageUseCase {
  final AiStylistRepository repository;

  SendChatMessageUseCase(this.repository);

  Future<Either<Failure, ChatMessageResult>> call({
    String? chatId,
    required String message,
  }) {
    return repository.sendMessage(chatId: chatId, message: message);
  }
}
