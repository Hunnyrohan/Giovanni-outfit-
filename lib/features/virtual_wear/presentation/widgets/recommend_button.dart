import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/virtual_wear_provider.dart';

class RecommendButton extends StatelessWidget {
  const RecommendButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VirtualWearProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onChrome = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return SizedBox(
      width: 165,
      height: 45,
      child: OutlinedButton(
        onPressed: provider.canGenerate ? () => context.read<VirtualWearProvider>().startTryOn() : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.25),
          side: BorderSide(color: onChrome, width: 1.5),
          disabledForegroundColor: onChrome.withValues(alpha: 0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Generate',
              style: GoogleFonts.outfit(
                color: provider.canGenerate ? onChrome : onChrome.withValues(alpha: 0.38),
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
