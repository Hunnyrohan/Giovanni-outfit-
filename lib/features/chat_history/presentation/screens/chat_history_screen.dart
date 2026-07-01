import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b0b0b),
      appBar: AppBar(
        backgroundColor: const Color(0xff0b0b0b),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chat history',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Center(
        child: Text(
          'No chat history yet',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
