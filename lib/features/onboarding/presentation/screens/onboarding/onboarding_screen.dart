import 'package:cal_scanner/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/widgets/activity_widget.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/widgets/age_widget.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/widgets/calorie_calculation_widget.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/widgets/gender_widget.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/widgets/health_goal_widget.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/widgets/height_widget.dart';
import 'package:cal_scanner/features/onboarding/presentation/screens/onboarding/widgets/weight_widget.dart';
import 'package:cal_scanner/imports/packages_imports.dart';
import 'package:cal_scanner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() async {
    if (_currentPage < 6) {
      if (_currentPage == 5) {
        await context.read<OnboardingCubit>().saveAndCalculate();
      }
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents keyboard from pushing up content
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(5),
              value: (_currentPage + 1) / 7,
              backgroundColor: AppColors.kLightGrey,
              valueColor: AlwaysStoppedAnimation(AppColors.kBlack),
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          GenderWidget(),
          AgeWidget(),

          HeightWidget(),
          WeightWidget(),
          ActivityWidget(),

          HealthGoalWidget(),
          CalorieCalculationWidget(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 48,
                width: 120,
                child: TextButton(
                  onPressed: _currentPage > 0
                      ? () => _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                      : null,
                  child: Text(
                    _currentPage > 0 ? 'Back' : '',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                width: 120,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == 6 ? 'Finish' : 'Next',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildWelcomePage() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Expanded(
  //           flex: 7,
  //           child: Image.asset(
  //             'assets/onboarding/onboarding_welcome.png',
  //             fit: BoxFit.cover,
  //             width: double.infinity,
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         Expanded(
  //           flex: 3,
  //           child: Column(
  //             children: [
  //               Text(
  //                 'Welcome to Calorie Lens!',
  //                 style: Theme.of(context).textTheme.headlineMedium,
  //                 textAlign: TextAlign.center,
  //               ),
  //               SizedBox(height: 16),
  //               Card(
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     children: [
  //                       Text(
  //                         'Your Daily Calorie Target',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                       SizedBox(height: 8),
  //                       Text(
  //                         '$estimatedCalories kcal',
  //                         style: TextStyle(
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.bold,
  //                           color: Theme.of(context).primaryColor,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
