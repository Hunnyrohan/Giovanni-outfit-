import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_drawer_item.dart';

class AppCustomDrawer extends StatelessWidget {
  const AppCustomDrawer({super.key});

  static const String _profileImage =
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=300&q=85';

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final drawerWidth = (screenSize.width * 0.77).clamp(270.0, 287.0);

    return SizedBox(
      width: drawerWidth,
      height: double.infinity,
      child: Material(
        color: const Color(0xff111111),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff151515),
                Color(0xff101010),
                Color(0xff121112),
              ],
              stops: [0, 0.58, 1],
            ),
          ),
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.only(top: 92, left: 15, right: 15),
              child: Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: _profileImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Georgia Smith',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'geosmith009@gmail.com',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppDrawerItem(
              icon: Icons.checkroom_outlined,
              label: 'My wardrobe',
              onTap: () => _openRoute(context, '/wardrobe'),
            ),
            AppDrawerItem(
              icon: Icons.favorite_border_rounded,
              label: 'Saved outfits',
              onTap: () => _openRoute(context, '/saved-outfits'),
            ),
            AppDrawerItem(
              icon: Icons.hub_outlined,
              label: 'AI Stylist',
              onTap: () => _openRoute(context, '/home'),
            ),
            AppDrawerItem(
              icon: Icons.history_rounded,
              label: 'Chat history',
              onTap: () => _openRoute(context, '/chat-history'),
            ),
            AppDrawerItem(
              icon: Icons.account_circle_outlined,
              label: 'Profile & setting',
              onTap: () => _openRoute(context, '/profile'),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xffff7f9f),
                        Color(0xffd878d2),
                        Color(0xff648cff),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Giovanni',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Personal AI stylist',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
