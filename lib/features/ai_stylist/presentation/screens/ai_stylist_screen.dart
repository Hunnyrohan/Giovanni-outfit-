import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/ai_stylist_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/ai_dots.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/suggestion_chips.dart';

class AiStylistScreen extends StatefulWidget {
  const AiStylistScreen({super.key});

  @override
  State<AiStylistScreen> createState() => _AiStylistScreenState();
}

class _AiStylistScreenState extends State<AiStylistScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _confirmReset(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xff1e1e1e) : Colors.white,
          title: Text(
            'Clear Conversation',
            style: GoogleFonts.poppins(color: onScreen, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to clear the conversation and start over?',
            style: GoogleFonts.poppins(color: onScreen.withValues(alpha: 0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: onScreen.withValues(alpha: 0.54)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AiStylistProvider>().clearConversation();
              },
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(color: const Color(0xff0066ff)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AiStylistProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    // Scroll to bottom when list changes, and surface any AI Stylist errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();

      final error = provider.errorMessage;
      if (error != null) {
        provider.clearError();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: const Color(0xffef586c),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff0d0d0d) : const Color(0xffF3F1EF),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [
                          const Color(0xff342527).withValues(alpha: 0.85),
                          const Color(0xff111111),
                          const Color(0xff140b20),
                        ]
                      : const [
                          Color(0xffE7DFD3),
                          Color(0xffF3F1EF),
                          Color(0xffECE7E9),
                        ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),

          // Main Scaffold Layout
          SafeArea(
            child: Column(
              children: [
                // Top Header Section
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, left: 20.0, right: 20.0, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular Back Button
                      GestureDetector(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: onScreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: onScreen,
                              size: 18,
                            ),
                          ),
                        ),
                      ),

                      // Title with Glowing AI Dots
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'AI stylist',
                            style: GoogleFonts.poppins(
                              color: onScreen,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 2.0),
                            child: AiDots(),
                          ),
                        ],
                      ),

                      // Circular Refresh Button
                      GestureDetector(
                        onTap: () => _confirmReset(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: onScreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.refresh_rounded,
                              color: onScreen,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat Messages Area
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.messages.length) {
                        return _buildTypingIndicator(context);
                      }
                      return ChatBubble(message: provider.messages[index]);
                    },
                  ),
                ),

                // Horizontal Suggestion Chips List
                SuggestionChips(
                  suggestions: provider.suggestions,
                  onChipTap: (text) {
                    provider.sendMessage(text, context.read<HistoryProvider>());
                  },
                ),

                const SizedBox(height: 6),

                // Floating Input Bar
                MessageInput(
                  selectedImage: provider.selectedImage,
                  onPickImage: (source) => provider.pickImage(source),
                  onClearImage: () => provider.clearSelectedImage(),
                  onSendMessage: (text) => provider.sendMessage(text, context.read<HistoryProvider>()),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 2.0),
                child: AiDots(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xff424242).withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return _buildTypingDot(isDark);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isDark ? Colors.white70 : Colors.black45,
        shape: BoxShape.circle,
      ),
    );
  }
}
