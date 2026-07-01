import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAvatarSection extends StatelessWidget {
  const ProfileAvatarSection({super.key});

  static const String _avatarAsset = 'assets/images/profile/profile_avatar.png';
  static const String _avatarUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330'
      '?auto=format&fit=crop&w=240&q=80';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 82,
          height: 82,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: Image.asset(
                  _avatarAsset,
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      _avatarUrl,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    );
                  },
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2F6BFF),
                      width: 1.3,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFF2F6BFF),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Georgia Smith',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'geosmith009@gmail.com',
          style: GoogleFonts.poppins(
            color: const Color(0xFFBDBDBD),
            fontSize: 10.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
