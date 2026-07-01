import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/recommended_outfit_entity.dart';
import 'outfit_recommendation_card.dart';

class RecommendedOutfitCarousel extends StatefulWidget {
  const RecommendedOutfitCarousel({
    super.key,
    required this.outfits,
    required this.onFavoriteTap,
  });

  final List<RecommendedOutfitEntity> outfits;
  final ValueChanged<String> onFavoriteTap;

  @override
  State<RecommendedOutfitCarousel> createState() =>
      _RecommendedOutfitCarouselState();
}

class _RecommendedOutfitCarouselState extends State<RecommendedOutfitCarousel> {
  late final PageController _controller;
  int _focusedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusedIndex = widget.outfits.length > 1 ? 1 : 0;
    _controller = PageController(
      viewportFraction: 0.51,
      initialPage: _focusedIndex,
    );
  }

  @override
  void didUpdateWidget(covariant RecommendedOutfitCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.outfits.length != oldWidget.outfits.length) {
      _focusedIndex = widget.outfits.length > 1 ? 1 : 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(_focusedIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.outfits.isEmpty) {
      return const SizedBox(height: 268);
    }

    return Column(
      children: [
        SizedBox(
          height: 218,
          child: PageView.builder(
            controller: _controller,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.outfits.length,
            onPageChanged: (index) => setState(() => _focusedIndex = index),
            itemBuilder: (context, index) {
              final outfit = widget.outfits[index];
              return Center(
                child: OutfitRecommendationCard(
                  outfit: outfit,
                  isFocused: index == _focusedIndex,
                  onFavoriteTap: () => widget.onFavoriteTap(outfit.id),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 1),
        SizedBox(
          width: 143,
          height: 32,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.black.withValues(alpha: 0.1),
            ),
            child: Text(
              'Try this virtually',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
