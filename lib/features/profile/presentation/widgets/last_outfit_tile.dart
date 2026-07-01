import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/last_outfit_entity.dart';

class LastOutfitTile extends StatelessWidget {
  const LastOutfitTile({required this.outfit, super.key});

  final LastOutfitEntity outfit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(left: 16, right: 12),
      decoration: BoxDecoration(
        color: const Color(0xff4b4b4b).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${outfit.title}  ${outfit.emoji}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
