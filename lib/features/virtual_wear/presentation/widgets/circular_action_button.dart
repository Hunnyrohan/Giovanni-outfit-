import 'package:flutter/material.dart';

class CircularActionButton extends StatelessWidget {
  const CircularActionButton({
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 46,
      height: 46,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 23,
        style: IconButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xff3e3e3e).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          shape: const CircleBorder(),
        ),
        icon: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF1E1E1E),
          size: 22,
        ),
      ),
    );
  }
}
