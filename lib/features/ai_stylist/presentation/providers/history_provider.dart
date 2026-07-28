import 'package:flutter/material.dart';
import '../../domain/entities/conversation_history.dart';
import '../../domain/usecases/delete_all_conversations_usecase.dart';
import '../../domain/usecases/delete_conversation_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';

class HistoryProvider extends ChangeNotifier {
  final GetChatHistoryUseCase getChatHistoryUseCase;
  final DeleteConversationUseCase deleteConversationUseCase;
  final DeleteAllConversationsUseCase deleteAllConversationsUseCase;

  HistoryProvider({
    required this.getChatHistoryUseCase,
    required this.deleteConversationUseCase,
    required this.deleteAllConversationsUseCase,
  }) {
    loadHistory();
  }

  final List<ConversationHistory> _historyList = [];
  bool _isLoading = false;

  List<ConversationHistory> get historyList => List.unmodifiable(_historyList);
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    final result = await getChatHistoryUseCase();
    _isLoading = false;

    result.fold(
      (failure) => notifyListeners(),
      (chats) {
        _historyList
          ..clear()
          ..addAll(chats);
        notifyListeners();
      },
    );
  }

  /// Inserts or replaces a conversation summary. Called by [AiStylistProvider]
  /// once the backend confirms a chat was created or updated by a new message.
  void upsertChatSummary(ConversationHistory summary) {
    final index = _historyList.indexWhere((item) => item.id == summary.id);

    if (index != -1) {
      _historyList[index] = summary;
    } else {
      _historyList.insert(0, summary);
    }
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    final removedIndex = _historyList.indexWhere((item) => item.id == id);
    if (removedIndex == -1) return;

    final removed = _historyList.removeAt(removedIndex);
    notifyListeners();

    final result = await deleteConversationUseCase(id);
    result.fold(
      (failure) {
        // Backend delete failed - restore the item rather than leave local
        // and server state out of sync.
        _historyList.insert(removedIndex, removed);
        notifyListeners();
      },
      (_) {},
    );
  }

  Future<void> deleteAllConversations() async {
    final previous = List<ConversationHistory>.from(_historyList);
    _historyList.clear();
    notifyListeners();

    final result = await deleteAllConversationsUseCase();
    result.fold(
      (failure) {
        _historyList
          ..clear()
          ..addAll(previous);
        notifyListeners();
      },
      (_) {},
    );
  }
}
