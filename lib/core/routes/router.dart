import 'package:cal_scanner/features/onboarding/presentation/screens/graph_screen.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/splash.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/onboarding/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/main_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/settings_screen.dart';
import 'app_routes.dart';

class AppRouter {
  final bool showOnboarding;
  final SharedPreferences prefs;

  AppRouter({required this.showOnboarding, required this.prefs});

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash, // 👈 always start at splash
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.main,
            name: AppRoutes.main,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.graph,
            name: AppRoutes.graph,
            builder: (context, state) => const GraphScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
      final location = state.matchedLocation;
      final isSplash = location == AppRoutes.splash;

      // Let splash handle its own navigation — don't redirect away from it
      if (isSplash) return null;

      if (!onboardingDone) return AppRoutes.onboarding;
      return null;
    },
  );
}
