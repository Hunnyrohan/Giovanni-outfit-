import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/security_provider.dart';
import '../widgets/security_form_widgets.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  Future<void> _confirmDeactivation(BuildContext context) async {
    final passwordController = TextEditingController();
    // The sheet owns a fresh SecurityProvider; the surrounding screen has none.
    final security = sl<SecurityProvider>();

    final deleted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff1c1c1e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: ChangeNotifierProvider.value(
          value: security,
          child: Consumer<SecurityProvider>(
            builder: (consumerContext, provider, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Deactivate account',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This permanently deletes your account, wardrobe, try-on history and chats. This cannot be undone.',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 20),
                SecurityTextField(
                  controller: passwordController,
                  label: 'Confirm your password',
                  obscureText: true,
                ),
                SecurityActionButton(
                  label: 'Delete my account',
                  isDestructive: true,
                  isBusy: provider.isBusy,
                  onPressed: () async {
                    final password = passwordController.text;
                    if (password.isEmpty) {
                      showSecuritySnack(
                        consumerContext,
                        'Enter your password to confirm',
                        isError: true,
                      );
                      return;
                    }
                    final success = await provider.deleteAccount(password);
                    if (!sheetContext.mounted) return;
                    if (success) {
                      Navigator.pop(sheetContext, true);
                    } else {
                      showSecuritySnack(
                        consumerContext,
                        provider.errorMessage ?? 'Could not delete account',
                        isError: true,
                      );
                    }
                  },
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    passwordController.dispose();

    if (deleted == true && context.mounted) {
      // Clears the local session; the server-side account is already gone,
      // so the remote logout inside is best-effort by design.
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

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
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(26, 16, 26, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(fallbackRoute: '/profile-settings'),
                ),
                const SizedBox(height: 32),
                Text(
                  'Privacy & security',
                  style: GoogleFonts.poppins(
                    color: AppColors.onScreenOf(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                _PrivacySettingTile(
                  title: 'Password',
                  subtitle: 'Change your current password.',
                  onTap: () => context.push('/change-password'),
                ),
                _PrivacySettingTile(
                  title: '2F Authentication',
                  subtitle: 'Enable 2 factor authentication.',
                  onTap: () => context.push('/two-factor'),
                ),
                _PrivacySettingTile(
                  title: 'Personal details',
                  subtitle: 'Change your personal details for the app.',
                  onTap: () => context.push('/personal-details'),
                ),
                _PrivacySettingTile(
                  title: 'Information & permission',
                  subtitle: 'Change information and app\'s permission.',
                  onTap: () => context.push('/info-permissions'),
                ),
                _PrivacySettingTile(
                  title: 'Account deactivation',
                  subtitle: 'Deactivate your account.',
                  onTap: () => _confirmDeactivation(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacySettingTile extends StatelessWidget {
  const _PrivacySettingTile({
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onScreen = AppColors.onScreenOf(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: onScreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: AppColors.onScreenMutedOf(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: onScreen,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
