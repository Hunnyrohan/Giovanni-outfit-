import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/logout_tile.dart';
import '../widgets/profile_avatar_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const List<String> _accountItems = [
    'Personal information',
    'Privacy & security',
    'Notifications',
    'App\'s permission',
  ];

  static const List<String> _helpItems = [
    'Terms & conditions',
    'FAQ & Help',
    'Privacy policy',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.screenGradientOf(context),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(26, 0, 26, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ProfileHeader(),
                const SizedBox(height: 4),
                const ProfileAvatarSection(),
                const SizedBox(height: 28),
                ProfileMenuSection(
                  title: 'Account settings',
                  items: _accountItems,
                  onItemTap: (item) {
                    if (item == 'Privacy & security') {
                      context.push('/privacy-security');
                    }
                  },
                ),
                const SizedBox(height: 24),
                const ProfileMenuSection(title: 'Help & support', items: _helpItems),
                const SizedBox(height: 32),
                const LogoutTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
