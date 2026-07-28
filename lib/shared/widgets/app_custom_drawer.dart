import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_drawer_item.dart';
import 'user_avatar.dart';

class AppCustomDrawer extends StatelessWidget {
  const AppCustomDrawer({super.key});

  void _openRoute(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.go(route);
  }

  void _pushRoute(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final drawerWidth = (screenSize.width * 0.77).clamp(270.0, 287.0);
    final user = context.watch<AuthProvider>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Per the design reference, the drawer content is white-on-dark in BOTH
    // themes; only the panel tone changes - near-black in dark mode, a mid
    // grey in light mode.
    return SizedBox(
      width: drawerWidth,
      height: double.infinity,
      child: Material(
        color: isDark ? const Color(0xff111111) : const Color(0xff6f6f6f),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xff151515),
                      Color(0xff101010),
                      Color(0xff121112),
                    ]
                  : const [
                      Color(0xff757575),
                      Color(0xff6e6e6e),
                      Color(0xff727072),
                    ],
              stops: const [0, 0.58, 1],
            ),
          ),
          child: Column(
            children: [
            Padding(
              padding: const EdgeInsets.only(top: 92, left: 15, right: 15),
              child: Row(
                children: [
                  UserAvatar(
                    imageUrl: user?.profilePicture,
                    name: user?.name ?? 'Guest',
                    size: 60,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.55),
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
              onTap: () => _openRoute(context, '/ai-stylist'),
            ),
            AppDrawerItem(
              icon: Icons.history_rounded,
              label: 'Chat history',
              onTap: () => _openRoute(context, '/chat-history'),
            ),
            AppDrawerItem(
              icon: Icons.account_circle_outlined,
              label: 'Profile & setting',
              onTap: () => _pushRoute(context, '/profile-settings'),
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
