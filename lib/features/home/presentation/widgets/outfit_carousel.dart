import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'outfit_card.dart';

class OutfitCarousel extends StatelessWidget {
  const OutfitCarousel({super.key, required this.category});

  final String category;

  static const Map<String, List<OutfitVisualType>> _outfitsByCategory = {
    'Office': [
      OutfitVisualType.whiteOutfit,
      OutfitVisualType.creamBlazer,
      OutfitVisualType.navyDress,
    ],
    'Casual Outings': [
      OutfitVisualType.beigeJacket,
      OutfitVisualType.whiteOutfit,
      OutfitVisualType.casualSet,
    ],
    'Formal Party': [
      OutfitVisualType.navyDress,
      OutfitVisualType.dateDress,
      OutfitVisualType.creamBlazer,
    ],
    'College': [
      OutfitVisualType.casualSet,
      OutfitVisualType.beigeJacket,
      OutfitVisualType.whiteOutfit,
    ],
    'Date Night': [
      OutfitVisualType.dateDress,
      OutfitVisualType.navyDress,
      OutfitVisualType.beigeJacket,
    ],
  };

  @override
  Widget build(BuildContext context) {
    final outfits =
        _outfitsByCategory[category] ?? _outfitsByCategory['Office']!;

    return Column(
      children: [
        SizedBox(
          height: 188,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -88,
                top: 2,
                child: OutfitCard(
                  type: outfits[0],
                  width: 142,
                  height: 188,
                ),
              ),
              Positioned(
                left: 240,
                top: 0,
                child: OutfitCard(
                  type: outfits[2],
                  width: 142,
                  height: 188,
                ),
              ),
              Positioned(
                left: 74,
                top: 0,
                child: OutfitCard(
                  type: outfits[1],
                  width: 158,
                  height: 188,
                  isFocused: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 134,
          height: 31,
          child: OutlinedButton(
            onPressed: () => context.push('/virtual-wear'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: Text(
              'Try this virtually',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
