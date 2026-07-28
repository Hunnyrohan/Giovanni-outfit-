import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'injection_container.dart' as di;
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/wardrobe/presentation/providers/wardrobe_provider.dart';
import 'features/ai_stylist/presentation/providers/ai_stylist_provider.dart';
import 'features/ai_stylist/presentation/providers/history_provider.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize manual / GetIt dependency injection registry
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => di.sl<ThemeProvider>(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => di.sl<AuthProvider>(),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => di.sl<HomeProvider>(),
        ),
        ChangeNotifierProvider<WardrobeProvider>(
          create: (_) => di.sl<WardrobeProvider>(),
        ),
        ChangeNotifierProvider<AiStylistProvider>(
          create: (_) => di.sl<AiStylistProvider>(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (_) => di.sl<HistoryProvider>(),
        ),
      ],
      child: const StyleSenseApp(),
    ),
  );
}





