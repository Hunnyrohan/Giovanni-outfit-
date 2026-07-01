import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 6,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 222,
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(31),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xfff2f2f2).withValues(alpha: 0.22),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xff8d76ff).withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(12, 12),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavCircleButton(
                    icon: Icons.home_outlined,
                    onTap: () => context.go('/home'),
                    backgroundColor: const Color(0xff424242),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/upload-outfit'),
                    child: Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xffff3f8c),
                          width: 2.3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xffff3f8c,
                            ).withValues(alpha: 0.26),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.center_focus_strong_rounded,
                        color: Colors.black,
                        size: 27,
                      ),
                    ),
                  ),
                  _NavCircleButton(
                    icon: Icons.person_outline_rounded,
                    onTap: () => context.go('/profile'),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  const _NavCircleButton({
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 54,
        height: 58,
        child: Center(
          child: Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
        ),
      ),
    );
  }
}
