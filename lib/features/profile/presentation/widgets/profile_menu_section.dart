import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_menu_tile.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    required this.title,
    required this.items,
    super.key,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF8C8C8C),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => ProfileMenuTile(
            title: item,
            onTap: () => debugPrint('$item tapped'),
          ),
        ),
      ],
    );
  }
}
