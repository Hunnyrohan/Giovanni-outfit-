import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../providers/security_provider.dart';
import '../widgets/security_form_widgets.dart';

/// Manage screen for TOTP two-factor authentication: shows current status,
/// walks through setup (secret -> authenticator app -> confirm code) and
/// allows disabling with a valid code.
class TwoFactorScreen extends StatelessWidget {
  const TwoFactorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SecurityProvider>()..loadTwoFactorStatus(),
      child: const _TwoFactorView(),
    );
  }
}

class _TwoFactorView extends StatefulWidget {
  const _TwoFactorView();

  @override
  State<_TwoFactorView> createState() => _TwoFactorViewState();
}

class _TwoFactorViewState extends State<_TwoFactorView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _startSetup() async {
    final provider = context.read<SecurityProvider>();
    final success = await provider.setupTwoFactor();
    if (!mounted) return;
    if (!success) {
      showSecuritySnack(
        context,
        provider.errorMessage ?? 'Could not start 2FA setup',
        isError: true,
      );
    }
  }

  Future<void> _confirmEnable() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      showSecuritySnack(context, 'Enter the 6-digit code from your authenticator app', isError: true);
      return;
    }
    final provider = context.read<SecurityProvider>();
    final success = await provider.enableTwoFactor(code);
    if (!mounted) return;
    if (success) {
      _codeController.clear();
      showSecuritySnack(context, 'Two-factor authentication is now ON');
    } else {
      showSecuritySnack(context, provider.errorMessage ?? 'Invalid code', isError: true);
    }
  }

  Future<void> _disable() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      showSecuritySnack(context, 'Enter the 6-digit code from your authenticator app', isError: true);
      return;
    }
    final provider = context.read<SecurityProvider>();
    final success = await provider.disableTwoFactor(code);
    if (!mounted) return;
    if (success) {
      _codeController.clear();
      showSecuritySnack(context, 'Two-factor authentication turned off');
    } else {
      showSecuritySnack(context, provider.errorMessage ?? 'Invalid code', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    final enabled = provider.twoFactorEnabled;
    final setup = provider.pendingSetup;
    final onScreen = AppColors.onScreenOf(context);
    final onScreenMuted = AppColors.onScreenMutedOf(context);

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '2F Authentication',
                        style: GoogleFonts.poppins(
                          color: onScreen,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (enabled != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: enabled
                              ? const Color(0xFF2E7D32).withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: enabled ? const Color(0xFF66BB6A) : Colors.white24,
                          ),
                        ),
                        child: Text(
                          enabled ? 'ON' : 'OFF',
                          style: GoogleFonts.poppins(
                            color: enabled ? const Color(0xFF9CE79F) : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Protect your account with a 6-digit code from an authenticator app (Google Authenticator, Authy, ...) required at every login.',
                  style: GoogleFonts.poppins(color: onScreenMuted, fontSize: 12),
                ),
                const SizedBox(height: 28),
                if (enabled == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(color: Colors.white24),
                    ),
                  )
                else if (enabled) ...[
                  Text(
                    'To turn off two-factor authentication, enter the current 6-digit code from your authenticator app.',
                    style: GoogleFonts.poppins(color: onScreen.withValues(alpha: 0.75), fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  SecurityTextField(
                    controller: _codeController,
                    label: 'Authenticator code',
                    hint: '123456',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  SecurityActionButton(
                    label: 'Turn off 2FA',
                    isBusy: provider.isBusy,
                    isDestructive: true,
                    onPressed: _disable,
                  ),
                ] else if (setup == null) ...[
                  _InfoCard(
                    children: [
                      _StepLine(number: '1', text: 'Tap "Set up 2FA" below to generate your secret key.'),
                      _StepLine(number: '2', text: 'Add it to an authenticator app (manual entry).'),
                      _StepLine(number: '3', text: 'Confirm with the 6-digit code the app shows.'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SecurityActionButton(
                    label: 'Set up 2FA',
                    isBusy: provider.isBusy,
                    onPressed: _startSetup,
                  ),
                ] else ...[
                  Text(
                    'Enter this secret key in your authenticator app:',
                    style: GoogleFonts.poppins(color: onScreen.withValues(alpha: 0.75), fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: setup.secret));
                      if (context.mounted) {
                        showSecuritySnack(context, 'Secret copied to clipboard');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorderOf(context)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              setup.secret,
                              style: GoogleFonts.robotoMono(
                                color: onScreen,
                                fontSize: 15,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          Icon(Icons.copy_rounded, color: onScreenMuted, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the key to copy it. Account name: your email, provider: StyleSense AI.',
                    style: GoogleFonts.poppins(color: onScreenMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 22),
                  SecurityTextField(
                    controller: _codeController,
                    label: 'Enter the 6-digit code to confirm',
                    hint: '123456',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  SecurityActionButton(
                    label: 'Confirm & turn on',
                    isBusy: provider.isBusy,
                    onPressed: _confirmEnable,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(color: AppColors.onScreenOf(context), fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.onScreenOf(context).withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
