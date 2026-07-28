import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StyleProfileHeader extends StatelessWidget {
  const StyleProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.go('/home'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xffffb0b0).withValues(alpha: 0.38)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: isDark
              ? null
              : Border.all(color: const Color(0xFF1E1E1E), width: 1.6),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? Colors.white : const Color(0xFF1E1E1E),
          size: 27,
        ),
      ),
    );
  }
}
