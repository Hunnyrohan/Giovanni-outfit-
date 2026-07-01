import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for splash animation (2.5 seconds to appreciate the premium design)
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    // Force reset completed_onboarding on startup so it always shows for testing
    await prefs.remove('completed_onboarding');
    final hasCompletedOnboarding = prefs.getBool('completed_onboarding') ?? false;

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (!hasCompletedOnboarding) {
      // Redirect to onboarding flow for first-time launch
      context.go('/onboarding');
    } else if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xff33271b), // Warm goldish center glow
              Color(0xff120f17), // Deep purple-black ambient transition
              Color(0xff0b090d), // Dark edge
            ],
            stops: [0.0, 0.65, 1.0],
            center: Alignment(0.1, 0.05), // Slightly off-center glow matching visual references
            radius: 1.3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo text with shader mask gradient
              GestureDetector(
                onDoubleTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('completed_onboarding');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Onboarding state reset! Restart the app to view onboarding.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xffff8fab), // Pinkish rose
                      Color(0xff6c63ff), // Lavender purple
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Giovanni',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Personal AI stylist',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
