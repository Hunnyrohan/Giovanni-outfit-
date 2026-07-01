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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff1e1e1e),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xffbdbdbd), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13.5,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: GoogleFonts.outfit(
                  color: Colors.grey.shade500,
                  fontSize: 13.5,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded, color: Color(0xffbdbdbd), size: 18),
            splashRadius: 20,
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
