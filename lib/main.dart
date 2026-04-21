import 'data/repositories/food_repository.dart';
import 'data/services/food_service.dart';
import 'imports/imports.dart';
import 'presentation/cubit/food_log_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'theme/theme.dart';

Future<void> _loadEnvironmentFile() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
    // Provide a fallback or handle error as needed
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadEnvironmentFile();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = !(prefs.getBool('onboarding_complete') ?? false);

  // Initialize services and repositories
  final foodService = FoodService();
  final foodRepository = FoodRepository(foodService, prefs);

  runApp(MyApp(showOnboarding: showOnboarding, foodRepository: foodRepository));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  final FoodRepository foodRepository;

  const MyApp({
    super.key,
    required this.showOnboarding,
    required this.foodRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return BlocProvider(
          create: (context) => FoodLogCubit(foodRepository)..loadDailyLog(),
          child: MaterialApp(
            theme: buildLightTheme(primaryColorHex: '#6750A4'),
            debugShowCheckedModeBanner: false,
            title: 'Calorie Tracker',

            home: showOnboarding ? OnboardingScreen() : MainScreen(),
            routes: {
              '/main': (context) => MainScreen(),
              '/home': (context) => HomeScreen(),
              '/onboarding': (context) => OnboardingScreen(),
              '/settings': (context) => SettingsScreen(),
              // Ensures `/home` route is defined
            },
          ),
        );
      },
    );
  }
}
