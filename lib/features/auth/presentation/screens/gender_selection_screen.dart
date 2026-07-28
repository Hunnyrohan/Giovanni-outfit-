import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/app_ambient_background.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  bool _isMale = true; // Default matching the toggle mockup
  bool _agreedToTerms = false; // State of terms checkbox

  void _onLetGoPressed() {
    if (_agreedToTerms) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the License Agreement & Privacy Policy.',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xffef586c),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final onScreenMuted = isDark ? Colors.grey.shade400 : const Color(0xFF6E6A70);

    return Scaffold(
      body: AppAmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Brand Logo Header (Matching Splash screen)
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xffff8fab), // Pinkish rose
                    Color(0xff6c63ff), // Lavender purple
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Giovanni',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              // Subtitle
              Text(
                'Personal AI stylish',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: onScreenMuted,
                  letterSpacing: 0.5,
                ),
              ),
              
              const Spacer(flex: 2),

              // Title
              Text(
                'Select your gender',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: onScreen,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 40),

              // Gender Selection Toggle Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GenderIconButton(
                    isSelected: !_isMale,
                    onTap: () => setState(() => _isMale = false),
                    painter: FemaleFacePainter(
                        color: !_isMale ? Colors.white : onScreen.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(width: 18),
                  _GenderIconButton(
                    isSelected: _isMale,
                    onTap: () => setState(() => _isMale = true),
                    painter: MaleFacePainter(
                        color: _isMale ? Colors.white : onScreen.withValues(alpha: 0.6)),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // Bottom Button "Let's go"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onLetGoPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffef586c),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Let's go",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Agreement Checkbox Link
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _agreedToTerms ? const Color(0xff00e676) : Colors.transparent,
                          border: Border.all(
                            color: _agreedToTerms
                                ? const Color(0xff00e676)
                                : onScreen.withValues(alpha: 0.24),
                            width: 1.8,
                          ),
                        ),
                        child: _agreedToTerms
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.black,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: onScreen,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to Giovanni AI stylish '),
                            TextSpan(
                              text: 'License Agreement\n& Privacy policy',
                              style: GoogleFonts.outfit(
                                color: const Color(0xff00e676),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single gender toggle button: an unselected muted circle, or a wider
/// highlighted pill with a checkmark badge when selected.
class _GenderIconButton extends StatelessWidget {
  const _GenderIconButton({
    required this.isSelected,
    required this.onTap,
    required this.painter,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: isSelected ? 92 : 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffef586c)
              : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(28),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xffef586c).withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: CustomPaint(size: const Size(26, 26), painter: painter),
            ),
            if (isSelected)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff00e676),
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Draws female face line-art outline (bangs, eyes, smile)
class FemaleFacePainter extends CustomPainter {
  final Color color;
  FemaleFacePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.32;

    // Face main outline
    canvas.drawCircle(Offset(cx, cy + 2), r, paint);

    // Eyes
    canvas.drawCircle(Offset(cx - 7, cy - 2), 2.2, fillPaint);
    canvas.drawCircle(Offset(cx + 7, cy - 2), 2.2, fillPaint);

    // Smile
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy + 4), radius: 5.5),
      0.2,
      2.74,
      false,
      paint,
    );

    // Hair path (rounded bangs)
    final hairPath = Path();
    hairPath.moveTo(cx - r - 2, cy);
    hairPath.quadraticBezierTo(cx - r, cy - r, cx, cy - r - 3);
    hairPath.quadraticBezierTo(cx + r, cy - r, cx + r + 2, cy);
    hairPath.lineTo(cx + r - 3, cy - 2);
    hairPath.quadraticBezierTo(cx + r - 6, cy - r + 3, cx, cy - r + 3);
    hairPath.quadraticBezierTo(cx - r + 6, cy - r + 3, cx - r + 3, cy - 2);
    hairPath.close();
    canvas.drawPath(hairPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Draws male face line-art outline
class MaleFacePainter extends CustomPainter {
  final Color color;
  MaleFacePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.32;

    // Face outline
    canvas.drawCircle(Offset(cx, cy + 2), r, paint);

    // Eyes
    canvas.drawCircle(Offset(cx - 7, cy - 2), 2.2, fillPaint);
    canvas.drawCircle(Offset(cx + 7, cy - 2), 2.2, fillPaint);

    // Smile
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy + 4), radius: 5.5),
      0.2,
      2.74,
      false,
      paint,
    );

    // Short hair on top
    final hairPath = Path();
    hairPath.moveTo(cx - r - 1, cy - 3);
    hairPath.quadraticBezierTo(cx - r + 3, cy - r, cx, cy - r - 5);
    hairPath.quadraticBezierTo(cx + r - 3, cy - r, cx + r + 1, cy - 3);
    hairPath.quadraticBezierTo(cx, cy - r + 3, cx - r - 1, cy - 3);
    hairPath.close();
    canvas.drawPath(hairPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Draws Male/Female symbols
class GenderSymbolPainter extends CustomPainter {
  final bool isMale;
  final Color color;

  GenderSymbolPainter({required this.isMale, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    if (isMale) {
      final double r = w * 0.22;
      final center = Offset(cx - 2, cy + 2);
      canvas.drawCircle(center, r, paint);

      // Arrow line diagonal
      canvas.drawLine(
        Offset(center.dx + r * 0.707, center.dy - r * 0.707),
        Offset(cx + w * 0.35, cy - h * 0.35),
        paint,
      );
      // Arrow heads
      canvas.drawLine(
        Offset(cx + w * 0.35, cy - h * 0.35),
        Offset(cx + w * 0.15, cy - h * 0.35),
        paint,
      );
      canvas.drawLine(
        Offset(cx + w * 0.35, cy - h * 0.35),
        Offset(cx + w * 0.35, cy - h * 0.15),
        paint,
      );
    } else {
      final double r = w * 0.22;
      final center = Offset(cx, cy - 3);
      canvas.drawCircle(center, r, paint);

      // Down vertical line
      canvas.drawLine(
        Offset(center.dx, center.dy + r),
        Offset(cx, cy + h * 0.35),
        paint,
      );
      // Cross line
      canvas.drawLine(
        Offset(cx - w * 0.15, cy + h * 0.22),
        Offset(cx + w * 0.15, cy + h * 0.22),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
