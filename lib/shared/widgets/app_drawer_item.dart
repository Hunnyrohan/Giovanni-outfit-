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
    // The drawer panel is dark in BOTH themes (near-black / mid grey), so
    // its content is always white - see AppCustomDrawer.
    const onSurface = Colors.white;

    return InkWell(
      onTap: onTap,
      splashColor: onSurface.withValues(alpha: 0.08),
      highlightColor: onSurface.withValues(alpha: 0.04),
      child: SizedBox(
        height: 43,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 11),
          child: Row(
            children: [
              Icon(icon, color: onSurface, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onSurface,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
