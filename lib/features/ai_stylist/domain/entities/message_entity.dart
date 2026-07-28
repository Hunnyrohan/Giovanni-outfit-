enum MessageSender {
  user,
  ai,
}

class MessageEntity {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final String? imageUrl;
  final String? status;

  const MessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.imageUrl,
    this.status,
  });

  MessageEntity copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    String? imageUrl,
    String? status,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
    );
  }
}
