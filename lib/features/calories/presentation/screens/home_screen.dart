// home_screen.dart

import 'package:cal_scanner/core/extensions/context_extension.dart';
import 'package:cal_scanner/core/extensions/widget_extension.dart';
import 'package:cal_scanner/features/calories/presentation/cubit/food_log_cubit.dart';
import 'package:cal_scanner/features/calories/presentation/cubit/food_log_state.dart';
import 'package:cal_scanner/features/calories/presentation/screens/scan_result_screen.dart';
import 'package:cal_scanner/features/calories/presentation/widgets/weekly_date_picker.dart';
import 'package:cal_scanner/theme/app_colors.dart';
import 'package:cal_scanner/theme/app_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/daily_tracker.dart';
import '../widgets/meal_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 50,
      );
      if (picked == null) return;
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<FoodLogCubit>(),
            child: ScanResultScreen(imageFile: picked),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to access ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(CupertinoIcons.camera, color: AppColors.kOrange),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(CupertinoIcons.photo, color: AppColors.kOrange),
                title: const Text('Upload from Gallery'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

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
        backgroundColor: AppColors.kOrange,
        onPressed: () => _showImageSourceSheet(context),
        child: Icon(
          CupertinoIcons.camera_viewfinder,
          size: 30.sp,
          color: context.colors.onPrimary,
        ),
      ),
    );
  }
}
