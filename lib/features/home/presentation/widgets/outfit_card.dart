import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum OutfitVisualType {
  whiteOutfit,
  creamBlazer,
  navyDress,
  beigeJacket,
  casualSet,
  dateDress,
}

class OutfitCard extends StatelessWidget {
  const OutfitCard({
    super.key,
    required this.type,
    required this.width,
    required this.height,
    this.isFocused = false,
  });

  final OutfitVisualType type;
  final double width;
  final double height;
  final bool isFocused;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isFocused ? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isFocused ? 11 : 14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _assetPathFor(type),
              fit: BoxFit.cover,
              alignment: _imageAlignmentFor(type),
              errorBuilder: (_, _, _) => CachedNetworkImage(
                imageUrl: _imageUrlFor(type),
                fit: BoxFit.cover,
                alignment: _imageAlignmentFor(type),
                placeholder: (_, _) => CustomPaint(
                  painter: _OutfitCardPainter(type),
                ),
                errorWidget: (_, _, _) => CustomPaint(
                  painter: _OutfitCardPainter(type),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Color(0xff8d8d8d),
                  size: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _assetPathFor(OutfitVisualType type) {
    return switch (type) {
      OutfitVisualType.whiteOutfit => 'assets/images/virtual_wear/white_outfit.png',
      OutfitVisualType.creamBlazer => 'assets/images/virtual_wear/cream_blazer.png',
      OutfitVisualType.navyDress => 'assets/images/virtual_wear/navy_dress.png',
      OutfitVisualType.beigeJacket => 'assets/images/virtual_wear/beige_jacket.png',
      OutfitVisualType.casualSet => 'assets/images/virtual_wear/casual_set.png',
      OutfitVisualType.dateDress => 'assets/images/virtual_wear/date_dress.png',
    };
  }

  String _imageUrlFor(OutfitVisualType type) {
    return switch (type) {
      OutfitVisualType.whiteOutfit =>
        'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=900&q=90',
      OutfitVisualType.creamBlazer =>
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&w=900&q=90',
      OutfitVisualType.navyDress =>
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=900&q=90',
      OutfitVisualType.beigeJacket =>
        'https://images.unsplash.com/photo-1485968579580-b6d095142e6e?auto=format&fit=crop&w=900&q=90',
      OutfitVisualType.casualSet =>
        'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=90',
      OutfitVisualType.dateDress =>
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=900&q=90',
    };
  }

  Alignment _imageAlignmentFor(OutfitVisualType type) {
    return Alignment.topCenter;
  }
}

class _OutfitCardPainter extends CustomPainter {
  const _OutfitCardPainter(this.type);

  final OutfitVisualType type;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = switch (type) {
          OutfitVisualType.navyDress => const Color(0xffd5c9b6),
          OutfitVisualType.beigeJacket => const Color(0xfff4eee4),
          OutfitVisualType.casualSet => const Color(0xfff5f1ec),
          OutfitVisualType.dateDress => const Color(0xffead9df),
          _ => const Color(0xfffbfaf8),
        },
    );

    switch (type) {
      case OutfitVisualType.whiteOutfit:
        _paintWhiteOutfit(canvas, size);
        break;
      case OutfitVisualType.creamBlazer:
        _paintCreamBlazer(canvas, size);
        break;
      case OutfitVisualType.navyDress:
        _paintNavyDress(canvas, size);
        break;
      case OutfitVisualType.beigeJacket:
        _paintBeigeJacket(canvas, size);
        break;
      case OutfitVisualType.casualSet:
        _paintCasualSet(canvas, size);
        break;
      case OutfitVisualType.dateDress:
        _paintDateDress(canvas, size);
        break;
    }
  }

  void _paintCreamBlazer(Canvas canvas, Size size) {
    final shadow = Paint()
      ..color = const Color(0xffcfc6bb).withValues(alpha: 0.36)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final seam = Paint()
      ..color = const Color(0xffb9aa9b)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    final softSeam = Paint()
      ..color = const Color(0xffd2c5b7)
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    final body = Path()
      ..moveTo(size.width * 0.18, size.height * 0.97)
      ..lineTo(size.width * 0.29, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.09,
        size.width * 0.72,
        size.height * 0.18,
      )
      ..lineTo(size.width * 0.83, size.height * 0.97)
      ..close();
    canvas.drawPath(body.shift(const Offset(0, 4)), shadow);
    canvas.drawPath(body, Paint()..color = const Color(0xffeee1d1));

    final leftSleeve = Path()
      ..moveTo(size.width * 0.14, size.height * 0.27)
      ..quadraticBezierTo(
        size.width * 0.04,
        size.height * 0.48,
        size.width * 0.1,
        size.height * 0.95,
      )
      ..lineTo(size.width * 0.28, size.height * 0.95)
      ..lineTo(size.width * 0.31, size.height * 0.24)
      ..close();
    final rightSleeve = Path()
      ..moveTo(size.width * 0.86, size.height * 0.27)
      ..quadraticBezierTo(
        size.width * 0.96,
        size.height * 0.48,
        size.width * 0.9,
        size.height * 0.95,
      )
      ..lineTo(size.width * 0.72, size.height * 0.95)
      ..lineTo(size.width * 0.69, size.height * 0.24)
      ..close();
    canvas.drawPath(leftSleeve, Paint()..color = const Color(0xffeadbca));
    canvas.drawPath(rightSleeve, Paint()..color = const Color(0xffe4d2be));
    canvas.drawPath(leftSleeve, softSeam);
    canvas.drawPath(rightSleeve, softSeam);

    final blouse = Path()
      ..moveTo(size.width * 0.41, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.17,
        size.width * 0.6,
        size.height * 0.2,
      )
      ..lineTo(size.width * 0.56, size.height * 0.96)
      ..lineTo(size.width * 0.45, size.height * 0.96)
      ..close();
    canvas.drawPath(blouse, Paint()..color = const Color(0xfff6eee5));

    final leftLap = Path()
      ..moveTo(size.width * 0.32, size.height * 0.17)
      ..lineTo(size.width * 0.51, size.height * 0.49)
      ..lineTo(size.width * 0.43, size.height * 0.96)
      ..lineTo(size.width * 0.3, size.height * 0.24)
      ..close();
    final rightLap = Path()
      ..moveTo(size.width * 0.69, size.height * 0.17)
      ..lineTo(size.width * 0.51, size.height * 0.49)
      ..lineTo(size.width * 0.59, size.height * 0.96)
      ..lineTo(size.width * 0.72, size.height * 0.24)
      ..close();

    canvas.drawPath(leftLap, Paint()..color = const Color(0xfff8efe7));
    canvas.drawPath(rightLap, Paint()..color = const Color(0xffdcc8b6));
    canvas.drawPath(leftLap, seam);
    canvas.drawPath(rightLap, seam);
    canvas.drawLine(
      Offset(size.width * 0.51, size.height * 0.49),
      Offset(size.width * 0.51, size.height * 0.96),
      seam,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.42,
          size.height * 0.16,
          size.width * 0.17,
          size.height * 0.045,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xff1b1714),
    );

    for (var i = 0; i < 5; i++) {
      final center = Offset(
        size.width * 0.56,
        size.height * (0.55 + i * 0.065),
      );
      canvas.drawCircle(center, 3.2, Paint()..color = const Color(0xff8c6b4b));
      canvas.drawCircle(center, 1.2, Paint()..color = const Color(0xfff8ead9));
    }

    _pocket(canvas, size, Offset(size.width * 0.16, size.height * 0.64));
    _pocket(canvas, size, Offset(size.width * 0.64, size.height * 0.64));
  }

  void _pocket(Canvas canvas, Size size, Offset offset) {
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
      Paint()..color = const Color(0xffddcbb8),
    );
  }

  void _paintWhiteOutfit(Canvas canvas, Size size) {
    final sleeve = Path()
      ..moveTo(size.width * -0.3, size.height * 0.04)
      ..quadraticBezierTo(
        size.width * 0.14,
        size.height * 0.1,
        size.width * 0.37,
        size.height * 0.38,
      )
      ..lineTo(size.width * 0.62, size.height * 0.88)
      ..lineTo(size.width * 0.33, size.height * 0.93)
      ..quadraticBezierTo(
        size.width * 0.07,
        size.height * 0.45,
        size.width * -0.2,
        size.height * 0.25,
      )
      ..close();
    canvas.drawPath(sleeve, Paint()..color = const Color(0xffeee9df));
    canvas.drawPath(
      sleeve,
      Paint()
        ..color = const Color(0xffd3cbc0)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  void _paintNavyDress(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width * 0.55, 0),
      Offset(size.width * 0.5, size.height * 0.13),
      Paint()
        ..color = const Color(0xffd8c6aa)
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.04),
      4,
      Paint()..color = const Color(0xfff3deb5),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.22,
          size.height * 0.2,
          size.width * 0.18,
          size.height * 0.55,
        ),
        const Radius.circular(20),
      ),
      Paint()..color = const Color(0xff1a2841),
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
      Paint()..color = const Color(0xff1a2841),
    );

    final body = Path()
      ..moveTo(size.width * 0.38, size.height * 0.15)
      ..lineTo(size.width * 0.66, size.height * 0.16)
      ..lineTo(size.width * 0.78, size.height * 0.95)
      ..lineTo(size.width * 0.28, size.height * 0.95)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xff132035));
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.15),
      Offset(size.width * 0.52, size.height * 0.95),
      Paint()
        ..color = const Color(0xff536179)
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(size.width * 0.29, size.height * 0.48),
      Offset(size.width * 0.76, size.height * 0.48),
      Paint()
        ..color = const Color(0xff0b1324)
        ..strokeWidth = 3,
    );
  }

  void _paintBeigeJacket(Canvas canvas, Size size) {
    final jacket = Paint()..color = const Color(0xffd8c5ae);
    final shirt = Paint()..color = const Color(0xfff7f3ed);
    final seam = Paint()
      ..color = const Color(0xffad9984)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.34,
          size.height * 0.18,
          size.width * 0.32,
          size.height * 0.72,
        ),
        const Radius.circular(8),
      ),
      shirt,
    );

    final left = Path()
      ..moveTo(size.width * 0.25, size.height * 0.18)
      ..lineTo(size.width * 0.48, size.height * 0.26)
      ..lineTo(size.width * 0.43, size.height * 0.93)
      ..lineTo(size.width * 0.18, size.height * 0.93)
      ..close();
    final right = Path()
      ..moveTo(size.width * 0.75, size.height * 0.18)
      ..lineTo(size.width * 0.52, size.height * 0.26)
      ..lineTo(size.width * 0.57, size.height * 0.93)
      ..lineTo(size.width * 0.82, size.height * 0.93)
      ..close();
    canvas.drawPath(left, jacket);
    canvas.drawPath(right, Paint()..color = const Color(0xffcdb89f));
    canvas.drawPath(left, seam);
    canvas.drawPath(right, seam);
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.28),
      Offset(size.width * 0.5, size.height * 0.9),
      seam,
    );
  }

  void _paintCasualSet(Canvas canvas, Size size) {
    final top = Paint()..color = const Color(0xffece4da);
    final denim = Paint()..color = const Color(0xff263d5d);
    final seam = Paint()
      ..color = const Color(0xffc7b9aa)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.32,
          size.height * 0.14,
          size.width * 0.36,
          size.height * 0.42,
        ),
        const Radius.circular(14),
      ),
      top,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.23,
          size.height * 0.22,
          size.width * 0.17,
          size.height * 0.45,
        ),
        const Radius.circular(16),
      ),
      top,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.6,
          size.height * 0.22,
          size.width * 0.17,
          size.height * 0.45,
        ),
        const Radius.circular(16),
      ),
      top,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.34, size.height * 0.55)
        ..lineTo(size.width * 0.66, size.height * 0.55)
        ..lineTo(size.width * 0.75, size.height * 0.94)
        ..lineTo(size.width * 0.56, size.height * 0.94)
        ..lineTo(size.width * 0.5, size.height * 0.65)
        ..lineTo(size.width * 0.44, size.height * 0.94)
        ..lineTo(size.width * 0.25, size.height * 0.94)
        ..close(),
      denim,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.94),
      seam,
    );
  }

  void _paintDateDress(Canvas canvas, Size size) {
    final dress = Paint()..color = const Color(0xff7a1f42);
    final highlight = Paint()..color = const Color(0xff9a3358);
    final body = Path()
      ..moveTo(size.width * 0.38, size.height * 0.14)
      ..lineTo(size.width * 0.62, size.height * 0.14)
      ..lineTo(size.width * 0.72, size.height * 0.52)
      ..lineTo(size.width * 0.82, size.height * 0.94)
      ..lineTo(size.width * 0.18, size.height * 0.94)
      ..lineTo(size.width * 0.28, size.height * 0.52)
      ..close();
    canvas.drawPath(body, dress);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.15)
        ..lineTo(size.width * 0.62, size.height * 0.52)
        ..lineTo(size.width * 0.5, size.height * 0.94)
        ..lineTo(size.width * 0.39, size.height * 0.52)
        ..close(),
      highlight,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.1),
      5,
      Paint()..color = const Color(0xffe9c2ca),
    );
  }

  @override
  bool shouldRepaint(covariant _OutfitCardPainter oldDelegate) =>
      oldDelegate.type != type;
}
