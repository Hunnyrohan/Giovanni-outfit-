import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

class StyleSenseApp extends StatefulWidget {
  const StyleSenseApp({super.key});

  @override
  State<StyleSenseApp> createState() => _StyleSenseAppState();
}

class _StyleSenseAppState extends State<StyleSenseApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Built once against the AuthProvider instance already registered above
    // this widget in main.dart's MultiProvider, so route guards observe the
    // same auth session the rest of the app reads from.
    _router = AppRouter.createRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
