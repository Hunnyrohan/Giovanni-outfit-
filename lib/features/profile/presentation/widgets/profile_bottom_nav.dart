import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileBottomNav extends StatelessWidget {
  const ProfileBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 238,
      height: 66,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 238,
              height: 57,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.91)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(31),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.16),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 82,
                    height: 57,
                    child: IconButton(
                      onPressed: () => context.go('/home'),
                      padding: EdgeInsets.zero,
                      splashRadius: 27,
                      icon: Icon(
                        Icons.home_outlined,
                        color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                        size: 29,
                      ),
                    ),
                  ),
                  const SizedBox(width: 58),
                  SizedBox(
                    width: 82,
                    height: 57,
                    child: IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      splashRadius: 26,
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xff505050)
                              : const Color(0xffE4E0DC),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: isDark ? Colors.white : const Color(0xFF1E1E1E),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => context.push('/virtual-wear'),
              child: Container(
                width: 51,
                height: 51,
                padding: const EdgeInsets.all(3.5),
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
                  child: const Center(child: _PersonScannerIcon()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonScannerIcon extends StatelessWidget {
  const _PersonScannerIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(38, 38),
      painter: _PersonScannerPainter(),
    );
  }
}

class _PersonScannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bracket = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    void drawCorner(Offset start, Offset bend, Offset end) {
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(bend.dx, bend.dy)
          ..lineTo(end.dx, end.dy),
        bracket,
      );
    }

    drawCorner(
      Offset(w * .14, h * .34),
      Offset(w * .14, h * .14),
      Offset(w * .34, h * .14),
    );
    drawCorner(
      Offset(w * .66, h * .14),
      Offset(w * .86, h * .14),
      Offset(w * .86, h * .34),
    );
    drawCorner(
      Offset(w * .14, h * .66),
      Offset(w * .14, h * .86),
      Offset(w * .34, h * .86),
    );
    drawCorner(
      Offset(w * .66, h * .86),
      Offset(w * .86, h * .86),
      Offset(w * .86, h * .66),
    );

    canvas.drawCircle(Offset(w * .5, h * .3), w * .07, fill);
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
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * .4, h * .47), Offset(w * .4, h * .65), limb);
    canvas.drawLine(Offset(w * .6, h * .47), Offset(w * .6, h * .65), limb);
    canvas.drawLine(Offset(w * .47, h * .56), Offset(w * .47, h * .78), limb);
    canvas.drawLine(Offset(w * .53, h * .56), Offset(w * .53, h * .78), limb);

    final scanLine = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(w * .23, h * .45),
      Offset(w * .77, h * .45),
      scanLine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
