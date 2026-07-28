import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'ai_dots.dart';

class ChatHistoryHeader extends StatelessWidget {
  const ChatHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Row(
      children: [
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
        const SizedBox(width: 12),
        const Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: AiDots(),
        ),
        const SizedBox(width: 8),
        Text(
          'Chat history',
          style: GoogleFonts.poppins(
            color: onScreen,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
