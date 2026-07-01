import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiSearchBar extends StatelessWidget {
  const AiSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 14, right: 13),
      decoration: BoxDecoration(
        color: const Color(0xff858585).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        children: [
          const _BlueDots(),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 24,
            color: Colors.white.withValues(alpha: 0.55),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ask Giovanni to enhance your outfit',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: const Color(0xfff1f1f1),
                fontSize: 10.6,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlueDots extends StatelessWidget {
  const _BlueDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 18,
      child: Stack(children: [_dot(left: 7, top: 0), _dot(left: 0, top: 9)]),
    );
  }

  Widget _dot({required double left, required double top}) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xff70b8ff),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
