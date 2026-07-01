import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiTitleSection extends StatelessWidget {
  const AiTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Ask your personal\nAI stylish',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            height: 1.22,
            letterSpacing: 1.15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 5),
        const Padding(padding: EdgeInsets.only(bottom: 4), child: _AiDots()),
      ],
    );
  }
}

class _AiDots extends StatelessWidget {
  const _AiDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        children: [
          _dot(left: 0, top: 9, size: 6),
          _dot(left: 9, top: 1, size: 7),
          _dot(left: 10, top: 12, size: 4),
        ],
      ),
    );
  }

  Widget _dot({
    required double left,
    required double top,
    required double size,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xff6db8ff),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff6db8ff).withValues(alpha: 0.45),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
