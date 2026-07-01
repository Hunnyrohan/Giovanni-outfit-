import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StyleProfileHeader extends StatelessWidget {
  const StyleProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xffffb0b0).withValues(alpha: 0.38),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }
}
