import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: EdgeInsets.only(
          left: isActive ? 16 : 14,
          right: isActive ? 12 : 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          color: isActive
              ? Colors.white
              : const Color(0xff6b686b).withValues(alpha: 0.88),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isActive ? Colors.black : const Color(0xffc9c9c9),
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 7),
            Icon(
              isActive
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.chevron_right_rounded,
              color: isActive ? Colors.black : const Color(0xffbfbfbf),
              size: isActive ? 22 : 21,
            ),
          ],
        ),
      ),
    );
  }
}
