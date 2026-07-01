import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/last_outfit_entity.dart';
import 'last_outfit_tile.dart';

class LastOutfitList extends StatelessWidget {
  const LastOutfitList({required this.outfits, super.key});

  final List<LastOutfitEntity> outfits;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Last outfits',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.refresh_rounded, color: Colors.white, size: 21),
          ],
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < outfits.length; index++) ...[
          LastOutfitTile(outfit: outfits[index]),
          if (index != outfits.length - 1) const SizedBox(height: 7),
        ],
      ],
    );
  }
}
