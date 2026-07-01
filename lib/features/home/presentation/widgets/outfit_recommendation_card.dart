import 'package:flutter/material.dart';

import '../../domain/entities/recommended_outfit_entity.dart';

class OutfitRecommendationCard extends StatelessWidget {
  const OutfitRecommendationCard({
    super.key,
    required this.outfit,
    required this.isFocused,
    required this.onFavoriteTap,
  });

  final RecommendedOutfitEntity outfit;
  final bool isFocused;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isFocused ? 1 : 0.92,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Container(
        width: isFocused ? 174 : 136,
        height: isFocused ? 205 : 201,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFocused
                ? Colors.white
                : Colors.white.withValues(alpha: 0.28),
            width: isFocused ? 3 : 0,
          ),
          boxShadow: [
            if (isFocused)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isFocused ? 11 : 14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _OutfitIllustration(outfit: outfit),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.84),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      outfit.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: outfit.isFavorite
                          ? const Color(0xffff4f7b)
                          : const Color(0xff8a8a8a),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutfitIllustration extends StatelessWidget {
  const _OutfitIllustration({required this.outfit});

  final RecommendedOutfitEntity outfit;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OutfitPainter(outfit.title),
      child: const SizedBox.expand(),
    );
  }
}

class _OutfitPainter extends CustomPainter {
  const _OutfitPainter(this.title);

  final String title;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = title.contains('Navy')
            ? const Color(0xffd6cbb9)
            : const Color(0xfffbfaf8),
    );

    if (title.contains('Navy')) {
      _paintNavyDress(canvas, size);
    } else if (title.contains('White')) {
      _paintWhiteOutfit(canvas, size);
    } else {
      _paintCreamBlazer(canvas, size);
    }
  }

  void _paintCreamBlazer(Canvas canvas, Size size) {
    final shadow = Paint()
      ..color = const Color(0xffcfc5b9).withValues(alpha: 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final blazer = Paint()..color = const Color(0xffefe2d4);
    final seam = Paint()
      ..color = const Color(0xffc2b5a7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final body = Path()
      ..moveTo(size.width * 0.23, size.height * 0.97)
      ..lineTo(size.width * 0.3, size.height * 0.13)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.05,
        size.width * 0.7,
        size.height * 0.13,
      )
      ..lineTo(size.width * 0.78, size.height * 0.97)
      ..close();
    canvas.drawPath(body.shift(const Offset(0, 4)), shadow);
    canvas.drawPath(body, blazer);

    final leftLap = Path()
      ..moveTo(size.width * 0.31, size.height * 0.14)
      ..lineTo(size.width * 0.51, size.height * 0.47)
      ..lineTo(size.width * 0.43, size.height * 0.96)
      ..lineTo(size.width * 0.29, size.height * 0.23)
      ..close();
    final rightLap = Path()
      ..moveTo(size.width * 0.69, size.height * 0.14)
      ..lineTo(size.width * 0.51, size.height * 0.47)
      ..lineTo(size.width * 0.58, size.height * 0.96)
      ..lineTo(size.width * 0.71, size.height * 0.23)
      ..close();
    canvas.drawPath(leftLap, Paint()..color = const Color(0xfff8efe7));
    canvas.drawPath(rightLap, Paint()..color = const Color(0xffe7d6c5));
    canvas.drawPath(leftLap, seam);
    canvas.drawPath(rightLap, seam);

    canvas.drawLine(
      Offset(size.width * 0.51, size.height * 0.47),
      Offset(size.width * 0.51, size.height * 0.96),
      seam,
    );
    for (var i = 0; i < 4; i++) {
      final center = Offset(
        size.width * 0.56,
        size.height * (0.56 + i * 0.075),
      );
      canvas.drawCircle(center, 3, Paint()..color = const Color(0xff9a7b57));
      canvas.drawCircle(center, 1.1, Paint()..color = const Color(0xfff5eadb));
    }
    _paintPocket(canvas, size, Offset(size.width * 0.22, size.height * 0.62));
    _paintPocket(canvas, size, Offset(size.width * 0.6, size.height * 0.62));
  }

  void _paintPocket(Canvas canvas, Size size, Offset offset) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          size.width * 0.2,
          size.height * 0.055,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xffe1d0bd),
    );
  }

  void _paintWhiteOutfit(Canvas canvas, Size size) {
    final sleeve = Path()
      ..moveTo(size.width * -0.26, size.height * 0.02)
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.1,
        size.width * 0.39,
        size.height * 0.38,
      )
      ..lineTo(size.width * 0.6, size.height * 0.88)
      ..lineTo(size.width * 0.33, size.height * 0.93)
      ..quadraticBezierTo(
        size.width * 0.08,
        size.height * 0.45,
        size.width * -0.18,
        size.height * 0.25,
      )
      ..close();
    canvas.drawPath(sleeve, Paint()..color = const Color(0xffeee9e0));
    canvas.drawPath(
      sleeve,
      Paint()
        ..color = const Color(0xffd5cec3)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintNavyDress(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width * 0.54, 0),
      Offset(size.width * 0.5, size.height * 0.13),
      Paint()
        ..color = const Color(0xffd9c9ad)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(size.width * 0.54, size.height * 0.04),
      4,
      Paint()..color = const Color(0xfff4dfb6),
    );

    final body = Path()
      ..moveTo(size.width * 0.38, size.height * 0.15)
      ..lineTo(size.width * 0.66, size.height * 0.16)
      ..lineTo(size.width * 0.77, size.height * 0.95)
      ..lineTo(size.width * 0.28, size.height * 0.95)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xff132035));

    final sleeve = Paint()..color = const Color(0xff1b2942);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.23,
          size.height * 0.2,
          size.width * 0.18,
          size.height * 0.55,
        ),
        const Radius.circular(20),
      ),
      sleeve,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.64,
          size.height * 0.2,
          size.width * 0.18,
          size.height * 0.55,
        ),
        const Radius.circular(20),
      ),
      sleeve,
    );
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.15),
      Offset(size.width * 0.52, size.height * 0.95),
      Paint()
        ..color = const Color(0xff55637b)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.48),
      Offset(size.width * 0.75, size.height * 0.48),
      Paint()
        ..color = const Color(0xff0b1324)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _OutfitPainter oldDelegate) =>
      oldDelegate.title != title;
}
