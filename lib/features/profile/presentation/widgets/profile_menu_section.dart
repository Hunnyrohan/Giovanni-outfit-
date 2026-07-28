import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import 'profile_menu_tile.dart';

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    required this.title,
    required this.items,
    this.onItemTap,
    super.key,
  });

  final String title;
  final List<String> items;
  final void Function(String)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: AppColors.onScreenMutedOf(context),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map(
          (item) => ProfileMenuTile(
            title: item,
            onTap: () {
              if (onItemTap != null) {
                onItemTap!(item);
              } else {
                debugPrint('$item tapped');
              }
            },
          ),
        ),
      ],
    );
  }
}
