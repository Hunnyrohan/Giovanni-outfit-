import '../../domain/entities/conversation_history.dart';
import 'message_model.dart';

class ConversationHistoryModel extends ConversationHistory {
  const ConversationHistoryModel({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.lastMessage,
    required super.messages,
  });

  /// Backend chat summaries only carry `updatedAt` (last-activity time) and
  /// no embedded `messages` — this is mapped onto [ConversationHistory.createdAt]
  /// since the chat history screen groups conversations by that field to mean
  /// "last touched", not "first created".
  factory ConversationHistoryModel.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'] as List<dynamic>?;

    return ConversationHistoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse((json['updatedAt'] ?? json['createdAt']) as String),
      lastMessage: (json['summary'] as String?) ?? (json['lastMessage'] as String?) ?? '',
      messages: messagesJson == null
          ? const []
          : messagesJson
              .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'updatedAt': createdAt.toIso8601String(),
      'summary': lastMessage,
      'messages': messages.map((m) => (m as MessageModel).toJson()).toList(),
    };
  }
}
