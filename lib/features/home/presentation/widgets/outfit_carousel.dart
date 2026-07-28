import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'outfit_card.dart';

class OutfitCarousel extends StatefulWidget {
  const OutfitCarousel({super.key, required this.category});

  final String category;

  @override
  State<OutfitCarousel> createState() => _OutfitCarouselState();
}

class _OutfitCarouselState extends State<OutfitCarousel> {
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
    'Formal': [
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

  // Tracks the slot index (0 = Left, 1 = Center/Focused, 2 = Right) for each of the 3 outfits
  late List<int> _slots;

  @override
  void initState() {
    super.initState();
    _slots = [0, 1, 2];
  }

  @override
  void didUpdateWidget(covariant OutfitCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      setState(() {
        _slots = [0, 1, 2];
      });
    }
  }

  void _selectOutfit(int index) {
    final currentSlot = _slots[index];
    if (currentSlot == 0) {
      setState(() {
        for (int j = 0; j < 3; j++) {
          if (_slots[j] == 0) {
            _slots[j] = 1;
          } else if (_slots[j] == 1) {
            _slots[j] = 2;
          } else if (_slots[j] == 2) {
            _slots[j] = 0;
          }
        }
      });
    } else if (currentSlot == 2) {
      setState(() {
        for (int j = 0; j < 3; j++) {
          if (_slots[j] == 2) {
            _slots[j] = 1;
          } else if (_slots[j] == 1) {
            _slots[j] = 0;
          } else if (_slots[j] == 0) {
            _slots[j] = 2;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfits =
        _outfitsByCategory[widget.category] ?? _outfitsByCategory['Office']!;

    // Build the list of cards with animated positioned widgets
    return SizedBox(
      height: 216,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < 3; i++)
            _buildAnimatedCard(
              outfit: outfits[i],
              slot: _slots[i],
              onTap: () => _selectOutfit(i),
            ),
          Positioned(
            left: 75, // Centered relative to the focused card (74 + (158 - 156)/2 = 75)
            top: 200, // Positioned fully below the 188-high card
            child: Builder(builder: (context) {
              // Per the design: white outline pill on the dark theme, dark
              // outline pill with dark text on the light theme.
              final outline = Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1E1E1E);

              return GestureDetector(
                onTap: () => context.push('/virtual-wear'),
                child: Container(
                  width: 156,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: outline, width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Try this virtually',
                    style: GoogleFonts.poppins(
                      color: outline,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({
    required OutfitVisualType outfit,
    required int slot,
    required VoidCallback onTap,
  }) {
    final double left = switch (slot) {
      0 => -88,
      1 => 74,
      _ => 240,
    };

    final double top = switch (slot) {
      1 => 0,
      _ => 12,
    };

    final double width = switch (slot) {
      1 => 158,
      _ => 142,
    };

    final double height = 188;
    final bool isFocused = slot == 1;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: OutfitCard(
          type: outfit,
          width: width,
          height: height,
          isFocused: isFocused,
        ),
      ),
    );
  }
}
