import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';

/// Light/dark switch in the Profile header. The knob sits left with a sun
/// icon in light mode and slides right with a moon icon in dark mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggle(),
      child: Container(
        width: 52,
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF48D8A8), Color(0xFF3A8CFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Icon(
                    Icons.light_mode_outlined,
                    color: Colors.white.withValues(alpha: isDark ? 0.6 : 0.0),
                    size: 15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.dark_mode_outlined,
                    color: Colors.white.withValues(alpha: isDark ? 0.0 : 0.6),
                    size: 15,
                  ),
                ),
              ],
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF3A8CFF),
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
