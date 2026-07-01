import 'package:flutter/material.dart';

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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF111111),
              Color(0xFF050505),
              Color(0xFF1A141D),
              Color(0xFF30212F),
            ],
            stops: [0.0, 0.46, 0.78, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(26, 0, 26, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(),
                SizedBox(height: 4),
                ProfileAvatarSection(),
                SizedBox(height: 28),
                ProfileMenuSection(
                  title: 'Account settings',
                  items: _accountItems,
                ),
                SizedBox(height: 15),
                ProfileMenuSection(title: 'Help & support', items: _helpItems),
                SizedBox(height: 20),
                LogoutTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
