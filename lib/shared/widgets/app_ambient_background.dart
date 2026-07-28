import 'package:flutter/material.dart';

/// Recreates the soft, multi-color ambient glow background used on the
/// auth flow screens (splash, onboarding, login, signup, gender selection)
/// in the Figma design. Dark theme: a near-black base with a warm brown/rust
/// glow near the top-left, an olive glow at the left-middle, and a
/// purple/magenta glow near the bottom-right. Light theme: a warm off-white
/// base with the same glow positions in softer, more saturated tones so
/// they stay visible against the lighter base.
class AppAmbientBackground extends StatelessWidget {
  const AppAmbientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: isDark ? const Color(0xff0a0908) : const Color(0xffF3F1EF)),
        Positioned(
          top: -90,
          left: -110,
          width: 380,
          height: 380,
          child: _Blob(
            color: isDark ? const Color(0xffa8683a) : const Color(0xffC9A876),
            alpha: isDark ? 0.55 : 0.5,
          ),
        ),
        Positioned(
          top: 260,
          left: -140,
          width: 420,
          height: 420,
          child: _Blob(
            color: isDark ? const Color(0xff96923f) : const Color(0xffAEA85E),
            alpha: isDark ? 0.42 : 0.38,
          ),
        ),
        Positioned(
          bottom: -160,
          right: -140,
          width: 480,
          height: 480,
          child: _Blob(
            color: isDark ? const Color(0xff8a3f78) : const Color(0xffB48AAE),
            alpha: isDark ? 0.55 : 0.45,
          ),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.alpha});

  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
