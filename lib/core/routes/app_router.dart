import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/gender_selection_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/outfit_analysis/presentation/screens/upload_outfit_screen.dart';
import '../../features/outfit_analysis/presentation/screens/analysis_result_screen.dart';
import '../../features/history/presentation/screens/outfit_history_screen.dart';
import '../../features/profile/presentation/screens/style_profile_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/virtual_wear/presentation/screens/virtual_wear_screen.dart';
import '../../features/virtual_wear/presentation/screens/recommendation_screen.dart';
import '../../features/chat_history/presentation/screens/chat_history_screen.dart';

// Wardrobe Screens
import '../../features/wardrobe/presentation/screens/my_wardrobe_screen.dart';
import '../../features/wardrobe/presentation/screens/saved_outfits_screen.dart';
import '../../features/wardrobe/presentation/screens/add_collection_screen.dart';
import '../../features/wardrobe/presentation/screens/capture_screen.dart';
import '../../features/wardrobe/presentation/screens/product_details_screen.dart';
import '../../features/wardrobe/domain/entities/wardrobe_item_entity.dart';

// Shell Layout
import '../../shared/widgets/main_bottom_nav.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: rootNavigatorKey,
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      // Onboarding
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Login
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      // Signup
      GoRoute(
        path: '/signup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SignupScreen(),
      ),
      // Gender Selection
      GoRoute(
        path: '/gender',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GenderSelectionScreen(),
      ),
      // Root stack pushed routes for Wardrobe module overlay
      GoRoute(
        path: '/saved-outfits',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SavedOutfitsScreen(),
      ),
      GoRoute(
        path: '/add-collection',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddCollectionScreen(),
      ),
      GoRoute(
        path: '/capture',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final item = state.extra as WardrobeItemEntity?;
          return CaptureScreen(item: item);
        },
      ),
      GoRoute(
        path: '/product-details',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final item = state.extra as WardrobeItemEntity?;
          return ProductDetailsScreen(item: item);
        },
      ),
      GoRoute(
        path: '/upload-outfit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const UploadOutfitScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/virtual-wear',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VirtualWearScreen(),
      ),
      GoRoute(
        path: '/outfit-suggestions',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RecommendationScreen(),
      ),
      GoRoute(
        path: '/chat-history',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ChatHistoryScreen(),
      ),
      // Main shell route with bottom navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainBottomNav(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          // Wardrobe
          GoRoute(
            path: '/wardrobe',
            builder: (context, state) => const MyWardrobeScreen(),
          ),
          // Outfit Analysis
          GoRoute(
            path: '/outfit-analysis',
            builder: (context, state) => const UploadOutfitScreen(),
            routes: [
              GoRoute(
                path: 'result',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const AnalysisResultScreen(),
              ),
            ],
          ),
          // Outfit History
          GoRoute(
            path: '/history',
            builder: (context, state) => const OutfitHistoryScreen(),
          ),
          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const StyleProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
