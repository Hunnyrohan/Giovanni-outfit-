import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../providers/style_profile_provider.dart';
import '../widgets/security_form_widgets.dart';

/// Edits the account's personal details (name, bio, phone, gender, date of
/// birth) against the real backend PATCH /profile endpoint.
class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<StyleProfileProvider>(),
      child: const _PersonalDetailsView(),
    );
  }
}

class _PersonalDetailsView extends StatefulWidget {
  const _PersonalDetailsView();

  @override
  State<_PersonalDetailsView> createState() => _PersonalDetailsViewState();
}

class _PersonalDetailsViewState extends State<_PersonalDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  String? _gender;
  DateTime? _dateOfBirth;
  bool _prefilled = false;

  static const _genders = ['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'];

  static String _genderLabel(String value) => switch (value) {
        'MALE' => 'Male',
        'FEMALE' => 'Female',
        'OTHER' => 'Other',
        _ => 'Prefer not to say',
      };

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _prefillFrom(StyleProfileProvider provider) {
    final user = provider.userProfile;
    if (user == null || _prefilled) return;
    _prefilled = true;
    _nameController.text = user.fullName;
    _bioController.text = user.bio ?? '';
    _phoneController.text = user.phoneNumber ?? '';
    _gender = user.gender;
    _dateOfBirth = user.dateOfBirth;
    if (_dateOfBirth != null) {
      _dobController.text = _formatDate(_dateOfBirth!);
    }
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) => Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<StyleProfileProvider>();
    final success = await provider.updateProfile(
      fullName: _nameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      gender: _gender,
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth,
    );

    if (!mounted) return;
    if (success) {
      showSecuritySnack(context, 'Personal details updated');
    } else {
      showSecuritySnack(
        context,
        provider.errorMessage ?? 'Could not update details',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StyleProfileProvider>();
    _prefillFrom(provider);

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
          child: provider.isLoading && !_prefilled
              ? const Center(child: CircularProgressIndicator(color: Colors.white24))
              : SingleChildScrollView(
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
                          'Personal details',
                          style: GoogleFonts.poppins(
                            color: AppColors.onScreenOf(context),
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          provider.userProfile?.email ?? '',
                          style: GoogleFonts.poppins(
                            color: AppColors.onScreenMutedOf(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 28),
                        SecurityTextField(
                          controller: _nameController,
                          label: 'Full name',
                          validator: (value) =>
                              (value == null || value.trim().length < 2)
                                  ? 'Name must be at least 2 characters'
                                  : null,
                        ),
                        SecurityTextField(
                          controller: _bioController,
                          label: 'Bio',
                          hint: 'Tell us about your style...',
                          maxLength: 500,
                        ),
                        SecurityTextField(
                          controller: _phoneController,
                          label: 'Phone number',
                          hint: '+977 98........',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            final valid = RegExp(r'^[+]?[0-9\s-]{7,20}$').hasMatch(value.trim());
                            return valid ? null : 'Enter a valid phone number';
                          },
                        ),
                        Text(
                          'Gender',
                          style: GoogleFonts.poppins(
                            color: AppColors.onScreenOf(context).withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _gender,
                          dropdownColor: const Color(0xFF232323),
                          style: GoogleFonts.poppins(color: AppColors.onScreenOf(context), fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceOf(context),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.surfaceBorderOf(context)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF7B63FF)),
                            ),
                          ),
                          hint: Text(
                            'Select gender',
                            style: GoogleFonts.poppins(color: AppColors.onScreenMutedOf(context), fontSize: 13),
                          ),
                          items: [
                            for (final g in _genders)
                              DropdownMenuItem(value: g, child: Text(_genderLabel(g))),
                          ],
                          onChanged: (value) => setState(() => _gender = value),
                        ),
                        const SizedBox(height: 18),
                        SecurityTextField(
                          controller: _dobController,
                          label: 'Date of birth',
                          hint: 'YYYY-MM-DD',
                          readOnly: true,
                          onTap: _pickDateOfBirth,
                        ),
                        const SizedBox(height: 10),
                        SecurityActionButton(
                          label: 'Save changes',
                          isBusy: provider.isSaving,
                          onPressed: _save,
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
