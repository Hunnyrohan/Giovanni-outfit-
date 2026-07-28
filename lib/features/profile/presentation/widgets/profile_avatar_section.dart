import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileAvatarSection extends StatelessWidget {
  const ProfileAvatarSection({super.key});

  Future<void> _pickAndUploadPicture(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (pickedFile == null) {
      return;
    }

    final success = await authProvider.updateProfilePicture(
      File(pickedFile.path),
    );

    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to update profile picture',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final name = user?.name ?? 'Guest';
    final email = user?.email ?? '';
    final isUpdating = authProvider.isUpdatingPicture;

    return Column(
      children: [
        SizedBox(
          width: 82,
          height: 82,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                imageUrl: user?.profilePicture,
                name: name,
                size: 82,
              ),
              if (isUpdating)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black45,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: -12,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: isUpdating ? null : () => _pickAndUploadPicture(context),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC7D3DF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF173F7A),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: GoogleFonts.poppins(
            color: AppColors.onScreenOf(context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: GoogleFonts.poppins(
            color: AppColors.onScreenMutedOf(context),
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
