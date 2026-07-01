import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HoldStillBadge extends StatelessWidget {
  const HoldStillBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 76,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xff9b9b9b).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Hold still',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
