import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/user_avatar.dart';

class ProfileAvatarLarge extends StatelessWidget {
  const ProfileAvatarLarge({
    required this.imageUrl,
    required this.name,
    super.key,
  });

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xff17100f),
            shape: BoxShape.circle,
          ),
          child: UserAvatar(
            imageUrl: imageUrl,
            name: name,
            size: 104,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.outfit(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1E1E1E),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
