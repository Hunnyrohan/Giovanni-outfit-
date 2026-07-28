import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/message_entity.dart';
import 'ai_dots.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  void _openImagePreview(BuildContext context, String imageUrl, bool isLocal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: isLocal
                  ? Image.file(File(imageUrl))
                  : CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAi = message.sender == MessageSender.ai;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) _buildAiAvatar(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                if (message.text.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAi
                          ? (isDark
                              ? const Color(0xff424242).withValues(alpha: 0.9)
                              : Colors.black.withValues(alpha: 0.08))
                          : const Color(0xff0066ff),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isAi ? 4 : 20),
                        bottomRight: Radius.circular(isAi ? 20 : 4),
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: GoogleFonts.poppins(
                        color: isAi && !isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ),
                if (message.imageUrl != null) ...[
                  if (message.text.isNotEmpty) const SizedBox(height: 6),
                  _buildImageCard(context),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isAi) _buildUserAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAiAvatar() {
    return Container(
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
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return UserAvatar(
      imageUrl: user?.profilePicture,
      name: user?.name ?? 'Guest',
      size: 32,
    );
  }

  Widget _buildImageCard(BuildContext context) {
    final isLocal = !message.imageUrl!.startsWith('http');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _openImagePreview(context, message.imageUrl!, isLocal),
      child: Container(
        width: 220,
        height: 140,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xff424242).withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isLocal
              ? Image.file(
                  File(message.imageUrl!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
        ),
      ),
    );
  }
}
