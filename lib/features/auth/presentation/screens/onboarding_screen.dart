import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/onboarding_illustrations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      title: 'Dress to impress',
      description: 'Scan, style, and shop—all in one place. Our AI-powered platform offers a seamless way to try on clothes virtually, get style advice tailored to your body, and purchase the looks you love.',
      illustration: DressToImpressIllustration(),
    ),
    _OnboardPage(
      title: 'Virtual Fitting Room',
      description: 'With just a simple scan, our AI stylist will tailor a virtual fitting room just for you. Try on different outfits, mix and match styles, and find the perfect look that complements your unique body shape.',
      illustration: VirtualFittingRoomIllustration(),
    ),
    _OnboardPage(
      title: 'Style me AI',
      description: 'our intelligent algorithm will suggest outfits that flatter and fit you perfectly. Experiment with virtual try-ons, discover new trends, and buy your favorites directly from our marketplace.',
      illustration: StyleMeAIIllustration(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('completed_onboarding', true);
      if (mounted) {
        context.go('/login');
      }
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xff2d231b), // Soft warm gold/brown center glow
              Color(0xff120f17), // Deep purple-black ambient transition
              Color(0xff09070b), // Deep dark edge
            ],
            stops: [0.0, 0.7, 1.0],
            center: Alignment(-0.5, -0.2), // Matches the left-shifted glow in the screenshot
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
              
              // Slidable content (Illustrations, Title, Description)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          // Custom high-fidelity vector illustration frame
                          page.illustration,
                          const SizedBox(height: 36),
                          // Title
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description paragraph
                          Text(
                            page.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                              height: 1.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicator dots (Fixed in place above the bottom navigation)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isActive = _currentIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Bottom Navigation Buttons (Back & Next)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button on the left (Hidden/Empty space on screen 1)
                    if (_currentIndex > 0)
                      GestureDetector(
                        onTap: _previousPage,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 46), // Keep empty space to maintain alignment

                    // Next / Get Started button on the right
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        decoration: BoxDecoration(
                          color: _currentIndex == _pages.length - 1
                              ? const Color(0xffef586c)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _currentIndex == _pages.length - 1
                                ? const Color(0xffef586c)
                                : Colors.white.withValues(alpha: 0.1),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentIndex == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white70,
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String title;
  final String description;
  final Widget illustration;

  const _OnboardPage({
    required this.title,
    required this.description,
    required this.illustration,
  });
}
