import 'conversation_history.dart';
import 'message_entity.dart';

/// Result of sending a message to the AI Stylist: the (possibly newly
/// created) conversation summary, the persisted user message, and the AI's
/// reply.
class ChatMessageResult {
  final ConversationHistory chat;
  final MessageEntity userMessage;
  final MessageEntity aiMessage;

  const ChatMessageResult({
    required this.chat,
    required this.userMessage,
    required this.aiMessage,
  });
}
