import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/user_avatar.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.onProfileTap, super.key});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final fullName = user?.name ?? 'Guest';
    final firstName = fullName.trim().split(RegExp(r'\s+')).first;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: UserAvatar(
              imageUrl: user?.profilePicture,
              name: fullName,
              size: 43,
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
                    color: onScreen,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  firstName,
                  style: GoogleFonts.poppins(
                    color: onScreen,
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
                backgroundColor: isDark
                    ? const Color(0xff5a5254).withValues(alpha: 0.75)
                    : Colors.black.withValues(alpha: 0.07),
                shape: const CircleBorder(),
              ),
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: isDark ? const Color(0xffd0d0d0) : const Color(0xFF3A3A3A),
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
