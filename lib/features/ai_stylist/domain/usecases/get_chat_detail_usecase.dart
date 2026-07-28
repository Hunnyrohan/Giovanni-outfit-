import '../../../../core/errors/failure.dart';
import '../entities/conversation_history.dart';
import '../repositories/ai_stylist_repository.dart';

class GetChatDetailUseCase {
  final AiStylistRepository repository;

  GetChatDetailUseCase(this.repository);

  Future<Either<Failure, ConversationHistory>> call(String chatId) {
    return repository.getHistoryDetail(chatId);
  }
}
