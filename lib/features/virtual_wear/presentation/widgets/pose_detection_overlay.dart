import 'package:flutter/material.dart';

class PoseDetectionOverlay extends StatelessWidget {
  const PoseDetectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(child: CustomPaint(painter: PoseDetectionPainter())),
    );
  }
}

class PoseDetectionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset p(double x, double y) => Offset(size.width * x, size.height * y);

    final head = p(0.51, 0.265);
    final leftShoulder = p(0.37, 0.33);
    final rightShoulder = p(0.63, 0.345);
    final chest = p(0.5, 0.39);
    final waist = p(0.5, 0.47);
    final leftElbow = p(0.28, 0.43);
    final rightElbow = p(0.72, 0.44);
    final leftWrist = p(0.22, 0.57);
    final rightWrist = p(0.75, 0.575);
    final hip = p(0.5, 0.66);
    final leftLeg = p(0.43, 0.86);
    final rightLeg = p(0.58, 0.86);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.55
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = Colors.white;

    void line(Offset a, Offset b) => canvas.drawLine(a, b, linePaint);
    void dot(Offset point) => canvas.drawCircle(point, 3.1, dotPaint);

    line(head, chest);
    line(leftShoulder, rightShoulder);
    line(leftShoulder, chest);
    line(rightShoulder, chest);
    line(chest, waist);
    line(leftShoulder, leftElbow);
    line(leftElbow, leftWrist);
    line(rightShoulder, rightElbow);
    line(rightElbow, rightWrist);
    line(waist, leftElbow);
    line(waist, rightElbow);
    line(waist, hip);
    line(hip, leftLeg);
    line(hip, rightLeg);

    for (final point in [
      head,
      leftShoulder,
      rightShoulder,
      chest,
      waist,
      leftElbow,
      rightElbow,
      leftWrist,
      rightWrist,
      hip,
    ]) {
      dot(point);
    }
  }

  @override
  bool shouldRepaint(covariant PoseDetectionPainter oldDelegate) => false;
}
