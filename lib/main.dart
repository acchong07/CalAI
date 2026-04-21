import 'package:cal_scanner/core/routes/router.dart';
import 'package:go_router/go_router.dart';

import 'data/repositories/food_repository.dart';
import 'data/services/food_service.dart';
import 'imports/imports.dart';
import 'presentation/cubit/food_log_cubit.dart';
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
        return BlocProvider(
          create: (context) => FoodLogCubit(foodRepository)..loadDailyLog(),
          child: MaterialApp.router(
            routerConfig: router,
            theme: buildLightTheme(),
            debugShowCheckedModeBanner: false,
            title: 'Calorie Tracker',
          ),
        );
      },
    );
  }
}
