import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({this.fallbackRoute = '/home', super.key});

  final String fallbackRoute;

  void _handleBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleColor = isDark ? const Color(0xFF333333) : const Color(0xFFE3DEDA);
    final foreground = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () => _handleBack(context),
        padding: EdgeInsets.zero,
        splashRadius: 26,
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: foreground, width: 1.5),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: foreground,
            size: 18,
          ),
        ),
      ),
    );
  }
}
