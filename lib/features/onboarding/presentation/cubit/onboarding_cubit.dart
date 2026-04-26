import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';
import '../../data/local/preference_manager.dart';
import '../../data/models/user_data.dart';
import '../../../../../core/utils/calorie_calculator.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  void updateWeight(double value) => emit(state.copyWith(weight: value));
  void updateHeight(double value) => emit(state.copyWith(height: value));
  void updateAge(int value) => emit(state.copyWith(age: value));
  void updateActivityLevel(String value) =>
      emit(state.copyWith(activityLevel: value));
  void updateGender(String value) => emit(state.copyWith(gender: value));
  void updateGoal(String value) => emit(state.copyWith(userGoal: value));

  Future<void> saveAndCalculate() async {
    double heightToCm(double feetInches) {
      final parts = feetInches.toString().split('.');
      final feet = int.parse(parts[0]);
      final inches = parts.length > 1 ? int.parse(parts[1]) : 0;
      final totalInches = (feet * 12) + inches;
      return totalInches * 2.54;
    }

    final heightInCm = heightToCm(state.height!);
    debugPrint('heightInCm: $heightInCm');
    debugPrint('weight: ${state.weight}');
    debugPrint('age: ${state.age}');
    debugPrint('activityLevel: ${state.activityLevel}');
    debugPrint('gender: ${state.gender}');
    debugPrint('goal: ${state.userGoal}');

    final maintenance = CalorieCalculator.fallbackEstimateCalories(
      weight: state.weight!,
      height: heightInCm,
      age: state.age!,
      activityLevel: state.activityLevel,
      gender: state.gender,
    );

    debugPrint('maintenance: $maintenance');

    final adjusted = CalorieCalculator.calculateCaloriesBasedOnGoal(
      maintenanceCalories: maintenance,
      goal: state.userGoal,
    );

    final macros = CalorieCalculator.calculateMacroGoals(
      calories: adjusted,
      goal: state.userGoal,
    );

    emit(
      state.copyWith(
        estimatedCalories: adjusted,
        proteinGoal: macros['proteinGoal']!.toDouble(),
        fatGoal: macros['fatGoal']!.toDouble(),
        carbsGoal: macros['carbsGoal']!.toDouble(),
      ),
    );

    final userData = UserData(
      weight: state.weight!,
      height: heightInCm,
      age: state.age!,
      activityLevel: state.activityLevel,
      gender: state.gender,
      goal: state.userGoal,
      estimatedCalories: adjusted,
      proteinGoal: macros['proteinGoal']!,
      fatGoal: macros['fatGoal']!,
      carbsGoal: macros['carbsGoal']!,
    );

    final prefs = await SharedPreferences.getInstance();
    final prefManager = PreferenceManager(prefs);
    await prefManager.saveUserData(userData);
    await prefs.setBool('onboarding_complete', true);
  }
}
