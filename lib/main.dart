import 'package:cal_scanner/core/routes/router.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/onboarding/data/repositories/food_repository.dart';
import 'features/onboarding/data/services/food_service.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'imports/imports.dart';
import 'features/onboarding/presentation/cubit/food_log_cubit.dart';
import 'theme/app_typography.dart';
import 'theme/theme.dart';

Future<void> _loadEnvironmentFile() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnvironmentFile();

  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);

  final foodService = FoodService();
  final foodRepository = FoodRepository(foodService, prefs);
  final appRouter = AppRouter(showOnboarding: showOnboarding, prefs: prefs);

  runApp(MyApp(router: appRouter.router, foodRepository: foodRepository));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final FoodRepository foodRepository;

  const MyApp({super.key, required this.router, required this.foodRepository});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => FoodLogCubit(foodRepository)..loadDailyLog(),
            ),
            BlocProvider(create: (context) => OnboardingCubit()),
          ],

          child: MaterialApp.router(
            routerConfig: router,
            theme: buildLightTheme().copyWith(
              textTheme: AppTypography.textTheme,
            ),

            debugShowCheckedModeBanner: false,
            title: 'AI Calorie Tracker',
          ),
        );
      },
    );
  }
}
