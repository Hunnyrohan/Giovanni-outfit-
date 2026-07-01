import 'package:flutter/material.dart';

class DashedOvalPreview extends StatelessWidget {
  const DashedOvalPreview({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _DashedOvalPainter(),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ClipOval(
            child: Transform.scale(
              scale: 1.18,
              alignment: const Alignment(0, -0.08),
              child: Image.asset(
                'assets/images/virtual_wear/body_preview.png',
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.08),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()..addOval(rect.deflate(2));
    final metric = path.computeMetrics().first;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var distance = 0.0;
    const dash = 13.0;
    const gap = 10.0;
    while (distance < metric.length) {
      final segment = metric.extractPath(distance, distance + dash);
      canvas.drawPath(segment, paint);
      distance += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedOvalPainter oldDelegate) => false;
}
