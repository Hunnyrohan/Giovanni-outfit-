import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WardrobeProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double? price;
  final double? rating;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTryVirtuallyTap;
  final VoidCallback onTap;
  final bool showTryVirtually;
  final bool showRatingDetails;

  const WardrobeProductCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.price,
    this.rating,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTryVirtuallyTap,
    required this.onTap,
    this.showTryVirtually = true,
    this.showRatingDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xffeeeeee),
                        child: const Center(
                          child: Icon(
                            Icons.checkroom_rounded,
                            color: Color(0xff8a8a8a),
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 7,
                      right: 7,
                      child: SizedBox(
                        width: 31,
                        height: 31,
                        child: IconButton(
                          onPressed: onFavoriteTap,
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(
                              0xff717171,
                            ).withValues(alpha: 0.82),
                            shape: const CircleBorder(),
                          ),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            if (showRatingDetails)
              Row(
                children: [
                  Text(
                    '705',
                    style: GoogleFonts.outfit(
                      fontSize: 6.8,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xffd8ff1f),
                    size: 10,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating?.toStringAsFixed(1) ?? '4.5',
                    style: GoogleFonts.outfit(
                      fontSize: 6.8,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '(21)',
                    style: GoogleFonts.outfit(
                      fontSize: 6.8,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ],
              ),
            if (showRatingDetails) const SizedBox(height: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.replaceAll('T-shirt', 't-shirt'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price != null
                            ? '\$${price!.toStringAsFixed(2)}'
                            : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showTryVirtually)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: OutlinedButton(
                      onPressed: onTryVirtuallyTap,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(73, 23),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        side: const BorderSide(color: Colors.white, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: Colors.white,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        'Try virtually',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
