import 'package:cal_scanner/core/extensions/capital_first_extension.dart';
import 'package:cal_scanner/core/extensions/num_extension.dart';
import 'package:cal_scanner/imports/imports.dart';
import 'package:cal_scanner/theme/app_colors.dart';
import 'package:cal_scanner/theme/app_typography.dart';
import 'package:flutter/material.dart';
import '../../data/models/food_item.dart';

class MealListItem extends StatelessWidget {
  final FoodItem meal;
  final String timeAgo;

  const MealListItem({super.key, required this.meal, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.kgrey.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name.capitalizeFirst(),
                  style: AppTypography.displaySmall.copyWith(fontSize: 18.sp),
                ),

                10.kH,
                Text('${meal.calories.toStringAsFixed(0)} kcal'),
              ],
            ),
          ),

          // Trailing icon
          Text(timeAgo, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}
