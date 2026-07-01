import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_assets.dart';

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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xff2d231b), // Soft warm gold/brown center glow
              Color(0xff120f17), // Deep purple-black ambient transition
              Color(0xff09070b), // Deep dark edge
            ],
            stops: [0.0, 0.7, 1.0],
            center: Alignment(-0.5, -0.2),
            radius: 1.5,
          ),
        ),
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
                  color: Colors.grey.shade400,
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
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 36),

              // Gender Selection Cards Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Female Card (Left)
                  GestureDetector(
                    onTap: () => setState(() => _isMale = false),
                    child: AnimatedScale(
                      scale: !_isMale ? 1.04 : 0.96,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      child: AnimatedOpacity(
                        opacity: !_isMale ? 1.0 : 0.55,
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: !_isMale 
                                  ? const Color(0xffef586c) 
                                  : Colors.white.withValues(alpha: 0.08),
                              width: !_isMale ? 2.0 : 1.0,
                            ),
                            boxShadow: !_isMale 
                                ? [
                                    BoxShadow(
                                      color: const Color(0xffef586c).withValues(alpha: 0.35),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                // Background Image (Female model)
                                Image.network(
                                  AppAssets.femaleModelPlaceholder,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.15),
                                        Colors.black.withValues(alpha: 0.85),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                // Selection Badge (Top Right)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: !_isMale 
                                          ? const Color(0xff00e676) 
                                          : Colors.black45,
                                      border: Border.all(
                                        color: !_isMale 
                                            ? const Color(0xff00e676) 
                                            : Colors.white30,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: !_isMale 
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.black,
                                          )
                                        : null,
                                  ),
                                ),
                                // Custom Face Painter Icon (Center)
                                Center(
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: Colors.white12,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(32, 32),
                                        painter: FemaleFacePainter(
                                          color: Colors.white.withValues(alpha: !_isMale ? 1.0 : 0.45),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Bottom Labels
                                Positioned(
                                  bottom: 14,
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'FEMALE',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Explore Women\'s Style',
                                        style: GoogleFonts.outfit(
                                          fontSize: 8.5,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Male Card (Right)
                  GestureDetector(
                    onTap: () => setState(() => _isMale = true),
                    child: AnimatedScale(
                      scale: _isMale ? 1.04 : 0.96,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      child: AnimatedOpacity(
                        opacity: _isMale ? 1.0 : 0.55,
                        duration: const Duration(milliseconds: 250),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isMale 
                                  ? const Color(0xffef586c) 
                                  : Colors.white.withValues(alpha: 0.08),
                              width: _isMale ? 2.0 : 1.0,
                            ),
                            boxShadow: _isMale 
                                ? [
                                    BoxShadow(
                                      color: const Color(0xffef586c).withValues(alpha: 0.35),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              children: [
                                // Background Image (Male model)
                                Image.network(
                                  AppAssets.maleModelPlaceholder,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withValues(alpha: 0.15),
                                        Colors.black.withValues(alpha: 0.85),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                // Selection Badge (Top Right)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isMale 
                                          ? const Color(0xff00e676) 
                                          : Colors.black45,
                                      border: Border.all(
                                        color: _isMale 
                                            ? const Color(0xff00e676) 
                                            : Colors.white30,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _isMale 
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.black,
                                          )
                                        : null,
                                  ),
                                ),
                                // Custom Face Painter Icon (Center)
                                Center(
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.08),
                                      border: Border.all(
                                        color: Colors.white12,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: CustomPaint(
                                        size: const Size(32, 32),
                                        painter: MaleFacePainter(
                                          color: Colors.white.withValues(alpha: _isMale ? 1.0 : 0.45),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Bottom Labels
                                Positioned(
                                  bottom: 14,
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'MALE',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Explore Men\'s Style',
                                        style: GoogleFonts.outfit(
                                          fontSize: 8.5,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                            color: _agreedToTerms ? const Color(0xff00e676) : Colors.white24,
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
                            color: Colors.white,
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
