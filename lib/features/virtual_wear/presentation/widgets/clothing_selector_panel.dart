import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/virtual_wear_provider.dart';

class ClothingSelectorPanel extends StatelessWidget {
  const ClothingSelectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VirtualWearProvider>();

    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.325,
      child: Column(
        children: [
          ...provider.clothes.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => provider.selectClothing(item),
                child: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xffe8ecef).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                    border: item.isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return CustomPaint(
                          painter: _TopThumbnailPainter(
                            isNavy: item.id == 'navy-top',
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add new clothing item')),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xffe8ecef).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopThumbnailPainter extends CustomPainter {
  const _TopThumbnailPainter({required this.isNavy});

  final bool isNavy;

  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()
      ..color = isNavy ? const Color(0xff121b32) : const Color(0xffd7c5ac)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final linePaint = Paint()
      ..color = isNavy ? const Color(0xff27334f) : const Color(0xff806f5f)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final body = Path()
      ..moveTo(size.width * 0.26, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.08,
        size.width * 0.43,
        size.height * 0.15,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.22,
        size.width * 0.57,
        size.height * 0.15,
      )
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.08,
        size.width * 0.74,
        size.height * 0.18,
      )
      ..lineTo(size.width * 0.84, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.9,
        size.width * 0.16,
        size.height * 0.75,
      )
      ..close();

    canvas.drawPath(body.shift(const Offset(0, 1.8)), shadowPaint);
    canvas.drawPath(body, topPaint);
    canvas.drawPath(body, linePaint);

    final neckPaint = Paint()
      ..color = const Color(0xffe8ecef)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.19),
        width: size.width * 0.18,
        height: size.height * 0.16,
      ),
      neckPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TopThumbnailPainter oldDelegate) {
    return oldDelegate.isNavy != isNavy;
  }
}
