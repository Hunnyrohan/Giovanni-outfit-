import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAddCollectionButton extends StatelessWidget {
  const ProfileAddCollectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.push('/add-collection'),
      style: TextButton.styleFrom(
        fixedSize: const Size(171, 47),
        backgroundColor: const Color(0xffeeeeee).withValues(alpha: 0.94),
        foregroundColor: const Color(0xff333333),
        shape: const StadiumBorder(),
        elevation: 5,
        shadowColor: Colors.black54,
      ),
      child: Text(
        '+ Add collection',
        style: GoogleFonts.outfit(
          color: const Color(0xff333333),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
