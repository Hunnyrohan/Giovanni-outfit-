import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WardrobeSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String placeholder;

  const WardrobeSearchBar({
    super.key,
    required this.onChanged,
    this.placeholder = 'Search more on marketplace',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: isDark ? const Color(0xffbdbdbd) : const Color(0xFF6E6A70), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                fontSize: 13.5,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: GoogleFonts.outfit(
                  color: Colors.grey.shade500,
                  fontSize: 13.5,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.tune_rounded, color: isDark ? const Color(0xffbdbdbd) : const Color(0xFF6E6A70), size: 18),
            splashRadius: 20,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
