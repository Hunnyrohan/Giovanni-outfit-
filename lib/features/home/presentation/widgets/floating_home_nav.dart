import 'package:flutter/material.dart';

import '../../../../core/routes/app_router.dart';

class FloatingHomeNav extends StatelessWidget {
  const FloatingHomeNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 186,
      height: 45,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.68 : 0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: const Color(0xff8c4d9a).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(10, 13),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            top: 0,
            child: _NavButton(
              onTap: () => AppRouter.router.go('/home'),
              child: Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xff505050) : const Color(0xffE4E0DC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                  size: 19,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2.5,
            child: _NavButton(
              onTap: () => AppRouter.router.go('/virtual-wear'),
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    startAngle: -2.35,
                    endAngle: 3.9332,
                    stops: [0, 0.24, 0.5, 0.75, 1],
                    colors: [
                      Color(0xff7b1fa2),
                      Color(0xff2547ff),
                      Color(0xff2547ff),
                      Color(0xffa31b8f),
                      Color(0xffff082f),
                    ],
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xffd8d8d8),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: _ScannerPersonIcon()),
                ),
              ),
            ),
          ),
          Positioned(
            right: 3,
            top: 0,
            child: _NavButton(
              onTap: () => AppRouter.router.go('/profile'),
              child: Icon(
                Icons.person_outline_rounded,
                color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 45,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        splashRadius: 22,
        icon: child,
      ),
    );
  }
}

class _ScannerPersonIcon extends StatelessWidget {
  const _ScannerPersonIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(28, 28), painter: _ScannerPainter());
  }
}

class _ScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bracket = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    void corner(Offset start, Offset bend, Offset end) {
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(bend.dx, bend.dy)
          ..lineTo(end.dx, end.dy),
        bracket,
      );
    }

    corner(
      Offset(w * .13, h * .34),
      Offset(w * .13, h * .13),
      Offset(w * .34, h * .13),
    );
    corner(
      Offset(w * .66, h * .13),
      Offset(w * .87, h * .13),
      Offset(w * .87, h * .34),
    );
    corner(
      Offset(w * .13, h * .66),
      Offset(w * .13, h * .87),
      Offset(w * .34, h * .87),
    );
    corner(
      Offset(w * .66, h * .87),
      Offset(w * .87, h * .87),
      Offset(w * .87, h * .66),
    );

    canvas.drawCircle(Offset(w * .5, h * .3), w * .072, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .4, h * .4, w * .2, h * .18),
        Radius.circular(w * .09),
      ),
      fill,
    );

    final limb = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * .4, h * .47), Offset(w * .4, h * .65), limb);
    canvas.drawLine(Offset(w * .6, h * .47), Offset(w * .6, h * .65), limb);
    canvas.drawLine(Offset(w * .47, h * .56), Offset(w * .47, h * .78), limb);
    canvas.drawLine(Offset(w * .53, h * .56), Offset(w * .53, h * .78), limb);

    canvas.drawLine(
      Offset(w * .22, h * .46),
      Offset(w * .78, h * .46),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
