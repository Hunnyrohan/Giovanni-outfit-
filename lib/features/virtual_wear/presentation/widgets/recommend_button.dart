import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendButton extends StatelessWidget {
  const RecommendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      height: 45,
      child: OutlinedButton(
        onPressed: () => context.push('/outfit-suggestions'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.black.withValues(alpha: 0.25),
          side: const BorderSide(color: Colors.white, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Recommend',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: Stack(
                children: [
                  Positioned(right: 1, top: 1, child: _Dot(size: 6)),
                  Positioned(left: 3, bottom: 2, child: _Dot(size: 5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xff72b8ff),
        shape: BoxShape.circle,
      ),
    );
  }
}
