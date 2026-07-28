import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/conversation_history.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_chat_detail_usecase.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';
import 'history_provider.dart';

class AiStylistProvider extends ChangeNotifier {
  final SendChatMessageUseCase sendChatMessageUseCase;
  final GetChatDetailUseCase getChatDetailUseCase;

  AiStylistProvider({
    required this.sendChatMessageUseCase,
    required this.getChatDetailUseCase,
  });

  final List<MessageEntity> _messages = [];
  bool _isLoadingConversation = false;
  bool _isTyping = false;
  File? _selectedImage;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();

  String? _activeConversationId;
  String _activeConversationTitle = 'New Chat';

  final List<String> _suggestions = [
    'beach parties',
    'birthday parties',
    'dinner parties',
    'office meeting',
    'wedding',
    'date night',
    'casual',
  ];

  List<MessageEntity> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoadingConversation;
  bool get isTyping => _isTyping;
  File? get selectedImage => _selectedImage;
  List<String> get suggestions => _suggestions;
  String? get activeConversationId => _activeConversationId;
  String get activeConversationTitle => _activeConversationTitle;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
  }

  void startNewConversation() {
    _activeConversationId = null;
    _activeConversationTitle = 'New Chat';
    _messages.clear();
    notifyListeners();
  }

  /// Loads a conversation selected from history. The screen navigates
  /// immediately with an empty message list which populates once the full
  /// conversation is fetched from the backend.
  Future<void> loadConversation(ConversationHistory conversation) async {
    _activeConversationId = conversation.id;
    _activeConversationTitle = conversation.title;
    _messages.clear();
    _isLoadingConversation = true;
    notifyListeners();

    final result = await getChatDetailUseCase(conversation.id);

    result.fold(
      (failure) {
        _isLoadingConversation = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (detail) {
        _messages
          ..clear()
          ..addAll(detail.messages);
        _isLoadingConversation = false;
        notifyListeners();
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void clearConversation() {
    startNewConversation();
  }

  Future<void> sendMessage(String text, HistoryProvider historyProvider) async {
    final String messageText = text.trim();
    if (messageText.isEmpty && _selectedImage == null) return;

    final String? localImagePath = _selectedImage?.path;
    _selectedImage = null;

    final String tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = MessageEntity(
      id: tempId,
      text: messageText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      imageUrl: localImagePath,
    );

    _messages.add(optimisticMessage);
    _isTyping = true;
    notifyListeners();

    // The AI Stylist chat endpoint is text-based; an attached photo still
    // shows in the chat bubble, but isn't analyzed here (see /ai/analyze).
    final outgoingMessage = messageText.isNotEmpty
        ? messageText
        : 'I attached a photo of my outfit - what do you think?';

    final result = await sendChatMessageUseCase(
      chatId: _activeConversationId,
      message: outgoingMessage,
    );

    result.fold(
      (failure) {
        _messages.removeWhere((message) => message.id == tempId);
        _isTyping = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (chatResult) {
        _activeConversationId = chatResult.chat.id;
        _activeConversationTitle = chatResult.chat.title;

        final index = _messages.indexWhere((message) => message.id == tempId);
        final confirmedUserMessage = optimisticMessage.copyWith(id: chatResult.userMessage.id);
        if (index != -1) {
          _messages[index] = confirmedUserMessage;
        } else {
          _messages.add(confirmedUserMessage);
        }
        _messages.add(chatResult.aiMessage);

        _isTyping = false;
        historyProvider.upsertChatSummary(chatResult.chat);
        notifyListeners();
      },
    );
  }
}
