import '../../../../core/errors/failure.dart';
import '../repositories/ai_stylist_repository.dart';

class DeleteConversationUseCase {
  final AiStylistRepository repository;

  DeleteConversationUseCase(this.repository);

  Future<Either<Failure, void>> call(String chatId) {
    return repository.deleteConversation(chatId);
  }
}
