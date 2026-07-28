import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';
import 'theme_toggle_button.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: AppBackButton(),
          ),
          Text(
            'Profile',
            style: GoogleFonts.poppins(
              color: AppColors.onScreenOf(context),
              fontSize: 22,
              fontWeight: FontWeight.w500,
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
