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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.white : const Color(0xff1e1e1e),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            size,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.black : const Color(0xffbdbdbd),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
