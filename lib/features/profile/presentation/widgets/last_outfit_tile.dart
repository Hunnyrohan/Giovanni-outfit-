import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/last_outfit_entity.dart';

class LastOutfitTile extends StatelessWidget {
  const LastOutfitTile({required this.outfit, super.key});

  final LastOutfitEntity outfit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onTile = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Container(
      height: 55,
      padding: const EdgeInsets.only(left: 16, right: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xff4b4b4b).withValues(alpha: 0.94)
            : const Color(0xffB9B7B4).withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${outfit.title}  ${outfit.emoji}',
              style: GoogleFonts.outfit(
                color: onTile,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(Icons.play_arrow_rounded, color: onTile, size: 28),
        ],
      ),
    );
  }
}
