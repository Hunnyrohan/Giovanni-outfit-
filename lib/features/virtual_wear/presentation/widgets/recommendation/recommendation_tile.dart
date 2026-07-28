import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationTile extends StatelessWidget {
  const RecommendationTile({
    required this.imageUrl,
    required this.text,
    super.key,
  });

  final String imageUrl;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.sizeOf(context).width / 351).clamp(0.88, 1.08);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 50 * scale,
              height: 50 * scale,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1E1E1E),
                fontSize: 14 * scale,
                fontWeight: FontWeight.w400,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
