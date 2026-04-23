import 'package:cal_scanner/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:cal_scanner/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:cal_scanner/imports/imports.dart';
import 'package:flutter/material.dart';

class CalorieCalculationWidget extends StatelessWidget {
  const CalorieCalculationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) => Text(
        '${state.estimatedCalories} kcal',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
