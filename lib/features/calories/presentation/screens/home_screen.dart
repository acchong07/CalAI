// home_screen.dart
import 'dart:async';

import 'package:cal_scanner/core/extensions/widget_extension.dart';
import 'package:cal_scanner/features/calories/presentation/cubit/food_log_cubit.dart';
import 'package:cal_scanner/features/calories/presentation/cubit/food_log_state.dart';
import 'package:cal_scanner/features/calories/presentation/widgets/weekly_date_picker.dart';
import 'package:cal_scanner/theme/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/daily_tracker.dart';
import '../widgets/meal_list.dart';

class HomeScreen extends StatefulWidget {
  final Widget? child;
  const HomeScreen({super.key, this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calorie Tracker',
          style: AppTypography.displaySmall.copyWith(fontSize: 19.sp),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── DATE PICKER ──────────────────────────────────────────────
              BlocBuilder<FoodLogCubit, FoodLogState>(
                builder: (context, state) {
                  return WeekDatePicker(
                    selectedDate: state.selectedDate,
                    onDateSelected: (date) {
                      context.read<FoodLogCubit>().selectDate(date);
                    },
                  );
                },
              ),

              // ────────────────────────────────────────────────────────────
              BlocBuilder<FoodLogCubit, FoodLogState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),
                      DailyTracker(
                        calories: state.totalCalories,
                        protein: state.totalProtein,
                        carbs: state.totalCarbs,
                        fat: state.totalFat,
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meals',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${state.meals.length} items',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 20.w),
                      const SizedBox(height: 16),
                      MealList(meals: state.meals),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<FoodLogCubit>().pickAndScanImage(context),
        child: Icon(CupertinoIcons.camera, size: 30.sp),
      ),
    );
  }
}

// ─── Week Date Picker Widget ──────────────────────────────────────────────────
