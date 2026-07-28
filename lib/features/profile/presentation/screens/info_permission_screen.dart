import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Explains what data and device permissions the app uses and where each
/// one can be changed. Device permissions themselves are granted/revoked in
/// the OS Settings app, which Android does not let apps change directly.
class InfoPermissionScreen extends StatelessWidget {
  const InfoPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppColors.screenGradientOf(context)),
        child: SafeArea(
          top: true,
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(26, 16, 26, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(fallbackRoute: '/privacy-security'),
                ),
                const SizedBox(height: 32),
                Text(
                  'Information & permission',
                  style: GoogleFonts.poppins(
                    color: AppColors.onScreenOf(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'YOUR INFORMATION',
                  style: GoogleFonts.poppins(
                    color: AppColors.onScreenMutedOf(context),
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoTile(
                  icon: Icons.badge_outlined,
                  title: 'Personal details',
                  subtitle: 'Name, bio, phone number, gender and date of birth. Stored on your StyleSense account.',
                  actionLabel: 'Edit',
                  onAction: () => context.push('/personal-details'),
                ),
                _InfoTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Your photos',
                  subtitle: 'Wardrobe and try-on photos you upload are stored with your account and used only to generate your results.',
                ),
                _InfoTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'AI Stylist chats',
                  subtitle: 'Chat history is saved so you can revisit conversations. Delete any conversation from Chat history.',
                ),
                const SizedBox(height: 24),
                Text(
                  'DEVICE PERMISSIONS THIS APP USES',
                  style: GoogleFonts.poppins(
                    color: AppColors.onScreenMutedOf(context),
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const _InfoTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera',
                  subtitle: 'Taking a photo for Virtual Try-On and adding wardrobe items.',
                ),
                const _InfoTile(
                  icon: Icons.image_outlined,
                  title: 'Photos / Gallery',
                  subtitle: 'Choosing an existing photo for Virtual Try-On and your profile picture.',
                ),
                const _InfoTile(
                  icon: Icons.wifi_rounded,
                  title: 'Internet',
                  subtitle: 'Syncing your wardrobe, AI chat and try-on generations with the StyleSense servers.',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorderOf(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, color: AppColors.onScreenMutedOf(context), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'To grant or revoke camera and photo permissions, open your phone\'s Settings > Apps > StyleSense AI > Permissions.',
                          style: GoogleFonts.poppins(
                            color: AppColors.onScreenOf(context).withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.onScreenOf(context), size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.onScreenOf(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: AppColors.onScreenMutedOf(context),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7B63FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
