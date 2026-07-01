import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawerItem extends StatelessWidget {
  const AppDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.04),
      child: SizedBox(
        height: 43,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 11),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
