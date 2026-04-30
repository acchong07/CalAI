import 'dart:io';

import 'package:cal_scanner/features/calories/presentation/cubit/food_log_state.dart';
import 'package:cal_scanner/features/calories/presentation/screens/scan_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';

class FoodLogCubit extends Cubit<FoodLogState> {
  final FoodRepository _repository;
  final ImagePicker _picker;

  FoodLogCubit(this._repository, [ImagePicker? picker])
    : _picker = picker ?? ImagePicker(),
      super(FoodLogState());

  Future<void> pickAndScanImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    emit(state.copyWith(selectedImage: image, isScanning: true));
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: this,
            child: ScanResultScreen(imageFile: image),
          ),
        ),
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));

    await addMealFromImage(image);
  }

  // fetch data view date

  Future<void> selectDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);

    emit(state.copyWith(selectedDate: normalized));
    await loadDailyLog();
  }

  Future<void> loadDailyLog({FoodItem? preserveScannedMeal}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _repository.getDailyFoodLog(state.selectedDate),
        _loadWeeklyData(),
      ]);

      final meals = results[0] as List<FoodItem>;
      final weeklyData = results[1] as List<double>;
      final totals = _calculateTotals(meals);

      emit(
        state.copyWith(
          meals: meals,
          totalCalories: totals['calories'],
          totalProtein: totals['protein'],
          totalCarbs: totals['carbs'],
          totalFat: totals['fat'],
          weeklyData: weeklyData,
          isLoading: false,
          scannedMeal: preserveScannedMeal ?? state.scannedMeal,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> addMeal(FoodItem meal) async {
    try {
      await _repository.addFoodItem(meal);
      await loadDailyLog();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Map<String, double> _calculateTotals(List<FoodItem> meals) {
    return meals.fold(
      {'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0},
      (totals, meal) {
        totals['calories'] = (totals['calories'] ?? 0) + meal.calories;
        totals['protein'] = (totals['protein'] ?? 0) + meal.protein;
        totals['carbs'] = (totals['carbs'] ?? 0) + meal.carbs;
        totals['fat'] = (totals['fat'] ?? 0) + meal.fat;
        return totals;
      },
    );
  }

  Future<List<double>> _loadWeeklyData() async {
    final now = DateTime.now();

    // Fetch all 7 days in parallel instead of sequentially
    final results = await Future.wait(
      List.generate(7, (i) {
        final date = now.subtract(Duration(days: 6 - i));
        return _repository.getDailyFoodLog(date);
      }),
    );

    return results
        .map((meals) => meals.fold(0.0, (sum, meal) => sum + meal.calories))
        .toList();
  }

  Future<void> addMealFromImage(File image) async {
    final result = await _repository.detectFoodFromImage(image);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            error: failure,
            successMessage: null,
            isScanning: false,
          ),
        );
      },
      (meal) async {
        emit(
          state.copyWith(
            scannedMeal: meal,
            isScanning: false,
            error: null,
            successMessage: 'Food "${meal.name}" detected successfully',
          ),
        );
        await _repository.addFoodItem(meal);
        await loadDailyLog(preserveScannedMeal: meal);
      },
    );
  }

  void clearMessages() {
    emit(
      FoodLogState(
        meals: state.meals,
        totalCalories: state.totalCalories,
        totalProtein: state.totalProtein,
        totalCarbs: state.totalCarbs,
        totalFat: state.totalFat,
        weeklyData: state.weeklyData,
        isLoading: state.isLoading,
        error: null,
        successMessage: null,
      ),
    );
  }

  Future<void> deleteMeal(FoodItem meal) async {
    try {
      await _repository.deleteFoodItem(meal);
      await loadDailyLog();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateMeal(FoodItem meal) async {
    try {
      await _repository.updateFoodItem(meal);
      await loadDailyLog();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  // re-build the UI at midnight for changes if user has't restart the app or crashed

  Future<void> refreshForNewDay() async {
    final today = DateTime.now();
    final normalized = DateTime(today.year, today.month, today.day);
    emit(state.copyWith(selectedDate: normalized));
    await loadDailyLog();
  }
}
