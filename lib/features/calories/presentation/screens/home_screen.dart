import 'package:cal_scanner/core/extensions/widget_extension.dart';
import 'package:cal_scanner/features/calories/presentation/cubit/food_log_cubit.dart';
import 'package:cal_scanner/features/calories/presentation/cubit/food_log_state.dart';
import 'package:cal_scanner/imports/imports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: Text('Calorie Tracker'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's trackers",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 16),
                BlocListener<FoodLogCubit, FoodLogState>(
                  listener: (context, state) {
                    if (state.successMessage != null || state.error != null) {
                      final isError = state.error != null;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 2),
                          backgroundColor: isError
                              ? Colors.red[100]
                              : Colors.green[100],
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          content: Row(
                            children: [
                              Icon(
                                isError ? Icons.error : Icons.check_circle,
                                color: isError ? Colors.red : Colors.green,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.error ?? state.successMessage ?? '',
                                  style: TextStyle(
                                    color: isError
                                        ? Colors.red[900]
                                        : Colors.green[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<FoodLogCubit, FoodLogState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return Center(child: CircularProgressIndicator());
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
                                '${state.meals.length.toString()} items',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          MealList(meals: state.meals),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
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
