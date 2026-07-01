import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go('/login'),
      child: SizedBox(
        height: 31,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFF1E1E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFFF1E1E),
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}
