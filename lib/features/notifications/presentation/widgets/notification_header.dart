import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _CircleButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
            Text(
              'Notification',
              style: GoogleFonts.outfit(
                color: onScreen,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _CircleButton(
                icon: Icons.menu_rounded,
                iconSize: 30,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onPressed,
    this.iconSize = 24,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 56,
      height: 56,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 28,
        style: IconButton.styleFrom(
          backgroundColor: isDark
              ? const Color(0xff5a5556).withValues(alpha: 0.78)
              : Colors.black.withValues(alpha: 0.07),
          shape: const CircleBorder(),
        ),
        icon: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF1E1E1E),
          size: iconSize,
        ),
      ),
    );
  }
}
