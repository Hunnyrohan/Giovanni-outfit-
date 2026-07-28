import '../../../../core/errors/failure.dart';
import '../entities/conversation_history.dart';
import '../repositories/ai_stylist_repository.dart';

class GetChatHistoryUseCase {
  final AiStylistRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<ConversationHistory>>> call() {
    return repository.getHistory();
  }
}
