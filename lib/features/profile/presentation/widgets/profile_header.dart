import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_router.dart';
import 'theme_toggle_button.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  void _handleBack() {
    AppRouter.router.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4D4D4D).withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: EdgeInsets.zero,
                child: IconButton(
                  onPressed: _handleBack,
                  padding: EdgeInsets.zero,
                  splashRadius: 25,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Profile',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: ThemeToggleButton(),
          ),
        ],
      ),
    );
  }
}
