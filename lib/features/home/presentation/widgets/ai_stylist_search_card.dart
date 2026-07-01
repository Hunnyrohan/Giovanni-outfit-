import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiStylistSearchCard extends StatelessWidget {
  const AiStylistSearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xff858584),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          const _BlueDotCluster(),
          Container(
            width: 1,
            height: 25,
            margin: const EdgeInsets.symmetric(horizontal: 13),
            color: Colors.white.withValues(alpha: 0.55),
          ),
          Expanded(
            child: Text(
              'Ask Giovanni to enhance your outfit',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.86),
                fontSize: 12.2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueDotCluster extends StatelessWidget {
  const _BlueDotCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 22,
      child: Stack(
        children: [
          _dot(left: 9, top: 2, size: 8),
          _dot(left: 3, top: 11, size: 6),
          _dot(left: 10, top: 14, size: 4),
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
          color: const Color(0xff8bbdff),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8bbdff).withValues(alpha: 0.45),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
