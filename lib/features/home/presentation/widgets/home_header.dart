import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.onProfileTap, super.key});

  final VoidCallback onProfileTap;

  static const String profileImage =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=85';

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: profileImage,
                width: 43,
                height: 43,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Georgia',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              padding: EdgeInsets.zero,
              splashRadius: 22,
              style: IconButton.styleFrom(
                backgroundColor: const Color(
                  0xff5a5254,
                ).withValues(alpha: 0.75),
                shape: const CircleBorder(),
              ),
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xffd0d0d0),
                    size: 21,
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xffe53935),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
    );
  }
}
