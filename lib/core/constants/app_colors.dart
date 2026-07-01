import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // Premium Palette
  static const Color primary = Color(0xff6c63ff); // lavender purple
  static const Color secondary = Color(0xffff8fab); // pinkish rose
  static const Color accent = Color(0xff4392f1); // blue accent for tech
  
  static const Color background = Color(0xfff8f8fc); // very light gray-blue
  static const Color cardBackground = Color(0xffffffff); // white card
  
  // Text Colors
  static const Color textDark = Color(0xff1e1e2f); // dark navy text
  static const Color textLight = Color(0xff7a7a8c); // slate gray text
  static const Color textOnPrimary = Color(0xffffffff); // white on primary
  
  // Status Colors
  static const Color success = Color(0xff2ec4b6);
  static const Color warning = Color(0xffffb703);
  static const Color error = Color(0xffe63946);
  static const Color info = Color(0xff00b4d8);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xff8b85ff)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xfff0f0f5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xff1e1e2f).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
}
