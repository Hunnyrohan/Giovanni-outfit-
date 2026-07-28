import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.text,
    required super.sender,
    required super.timestamp,
    super.imageUrl,
    super.status,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;

    return MessageModel(
      id: json['id'] as String,
      text: (json['content'] ?? json['text']) as String,
      sender: (json['sender'] as String).toUpperCase() == 'USER'
          ? MessageSender.user
          : MessageSender.ai,
      timestamp: DateTime.parse((json['createdAt'] ?? json['timestamp']) as String),
      imageUrl: metadata?['imageUrl'] as String? ?? json['imageUrl'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': text,
      'sender': sender == MessageSender.user ? 'USER' : 'AI',
      'createdAt': timestamp.toIso8601String(),
      'metadata': imageUrl != null ? {'imageUrl': imageUrl} : null,
      'status': status,
    };
  }
}
