import '../../../../core/errors/failure.dart';
import '../repositories/ai_stylist_repository.dart';

class DeleteAllConversationsUseCase {
  final AiStylistRepository repository;

  DeleteAllConversationsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deleteAllConversations();
  }
}
