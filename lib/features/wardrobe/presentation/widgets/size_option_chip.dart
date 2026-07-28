import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SizeOptionChip extends StatelessWidget {
  final String size;
  final bool isSelected;
  final VoidCallback onTap;

  const SizeOptionChip({
    super.key,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? onScreen
              : (isDark ? const Color(0xff1e1e1e) : Colors.black.withValues(alpha: 0.05)),
          border: Border.all(
            color: isSelected ? onScreen : onScreen.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            size,
            style: GoogleFonts.outfit(
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? const Color(0xffbdbdbd) : const Color(0xFF6E6A70)),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
