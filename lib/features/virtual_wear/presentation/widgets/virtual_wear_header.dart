import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class VirtualWearHeader extends StatelessWidget {
  const VirtualWearHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 18,
      left: 18,
      right: 18,
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _HeaderButton(
                icon: Icons.arrow_back_rounded,
                iconSize: 20,
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
              'Virtual wear on',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _HeaderButton(
                icon: Icons.settings_outlined,
                iconSize: 23,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Virtual wear settings')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 21,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xff4a4a4a).withValues(alpha: 0.85),
          shape: const CircleBorder(),
        ),
        icon: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
