import 'message_entity.dart';

class ConversationHistory {
  final String id;
  final String title;
  final DateTime createdAt;
  final String lastMessage;
  final List<MessageEntity> messages;

  const ConversationHistory({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessage,
    required this.messages,
  });

  ConversationHistory copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? lastMessage,
    List<MessageEntity>? messages,
  }) {
    return ConversationHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      messages: messages ?? this.messages,
    );
  }
}
