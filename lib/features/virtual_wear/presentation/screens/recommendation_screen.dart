import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/recommendation/dashed_oval_preview.dart';
import '../widgets/recommendation/recommendation_tile.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final scale = (screenSize.width / 351).clamp(0.88, 1.08);
    final horizontalPadding = 22.0 * scale;
    final previewWidth = 248.0 * scale;
    final previewHeight = 331.0 * scale;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onScreen = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xffF3F1EF),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xff151515),
                    Color(0xff090909),
                    Color(0xff151318),
                    Color(0xff352333),
                  ]
                : const [
                    Color(0xffEDE6DB),
                    Color(0xffF4F2F0),
                    Color(0xffF3F1EF),
                    Color(0xffE8DFE9),
                  ],
            stops: const [0, 0.45, 0.78, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                right: -62,
                top: -78,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xffa92929).withValues(alpha: 0.28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff9f2525).withValues(alpha: 0.45),
                        blurRadius: 85,
                        spreadRadius: 24,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      10 * scale,
                      horizontalPadding,
                      0,
                    ),
                    child: SizedBox(
                      height: 52 * scale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _HeaderCircleButton(
                              icon: Icons.arrow_back_rounded,
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/virtual-wear');
                                }
                              },
                            ),
                          ),
                          Text(
                            'Recommendation',
                            style: GoogleFonts.outfit(
                              color: onScreen,
                              fontSize: 24 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _HeaderCircleButton(
                              icon: Icons.file_download_outlined,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 36 * scale),
                  Center(
                    child: DashedOvalPreview(
                      width: previewWidth,
                      height: previewHeight,
                    ),
                  ),
                  SizedBox(height: 29 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Text(
                      'Recommendations:',
                      style: GoogleFonts.outfit(
                        color: onScreen,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  const RecommendationTile(
                    imageUrl:
                        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=120&auto=format&fit=crop&q=80',
                    text:
                        'You can additionally add a layering with chic blazer or a stylish kimono can add sophistication. \u{1F455}',
                  ),
                  SizedBox(height: 9 * scale),
                  const RecommendationTile(
                    imageUrl:
                        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=120&auto=format&fit=crop&q=80',
                    text:
                        'Choose a piece of jewelry that stands out, like a choker or large earrings. \u{1F48E}',
                  ),
                  SizedBox(height: 11 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Text(
                      'Generated by Giovanni AI',
                      style: GoogleFonts.outfit(
                        color: const Color(0xff40ff00),
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: SizedBox(
                      height: 49 * scale,
                      child: ElevatedButton(
                        onPressed: () => context.push('/add-collection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xffe7e7e7) : const Color(0xFF1E1E1E),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26 * scale),
                          ),
                        ),
                        child: Text(
                          'Buy Collections',
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.black : Colors.white,
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 29 * scale),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 49,
      height: 49,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xff5b5b5b).withValues(alpha: 0.78)
            : Colors.black.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 24.5,
        icon: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF1E1E1E),
          size: 26,
        ),
      ),
    );
  }
}
