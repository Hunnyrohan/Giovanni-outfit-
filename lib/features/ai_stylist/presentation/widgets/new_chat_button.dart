import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const NewChatButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xffa0a0a0),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_comment_outlined,
              color: Color(0xff2d2d2d),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'New chat',
              style: GoogleFonts.poppins(
                color: const Color(0xff2d2d2d),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
