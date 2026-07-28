import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../providers/security_provider.dart';
import '../widgets/security_form_widgets.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<SecurityProvider>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<SecurityProvider>();
    final success = await provider.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );

    if (!mounted) return;
    if (success) {
      showSecuritySnack(context, 'Password changed successfully');
      context.pop();
    } else {
      showSecuritySnack(
        context,
        provider.errorMessage ?? 'Could not change password',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SecurityProvider>();

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(fallbackRoute: '/privacy-security'),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Change password',
                    style: GoogleFonts.poppins(
                      color: AppColors.onScreenOf(context),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your new password must be at least 6 characters and different from the current one.',
                    style: GoogleFonts.poppins(
                      color: AppColors.onScreenMutedOf(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SecurityTextField(
                    controller: _currentController,
                    label: 'Current password',
                    obscureText: true,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Enter your current password'
                        : null,
                  ),
                  SecurityTextField(
                    controller: _newController,
                    label: 'New password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      if (value == _currentController.text) {
                        return 'New password must be different from the current one';
                      }
                      return null;
                    },
                  ),
                  SecurityTextField(
                    controller: _confirmController,
                    label: 'Confirm new password',
                    obscureText: true,
                    validator: (value) => value != _newController.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  SecurityActionButton(
                    label: 'Update password',
                    isBusy: provider.isBusy,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
