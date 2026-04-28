import 'dart:io';
import 'package:cal_scanner/core/extensions/capital_first_extension.dart';
import 'package:cal_scanner/core/extensions/num_extension.dart';
import 'package:cal_scanner/core/extensions/widget_extension.dart';

import 'package:cal_scanner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/food_item.dart';
import '../cubit/food_log_cubit.dart';
import '../cubit/food_log_state.dart';

class ScanResultScreen extends StatefulWidget {
  final File imageFile;
  const ScanResultScreen({super.key, required this.imageFile});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _dialogShown = false;
  FoodItem? _meal;
  String? _error;

  void _showDialog(BuildContext context) {
    _dialogShown = true;
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CupertinoActivityIndicator(radius: 14),
            SizedBox(height: 16),
            Text(
              'Analyzing your food...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Identifying dish & estimating nutrition',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _dismissDialog(BuildContext context) {
    if (_dialogShown) {
      _dialogShown = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<FoodLogCubit>().state;
    if (state.isScanning && !_dialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodLogCubit, FoodLogState>(
      listener: (context, state) {
        if (state.isScanning && !_dialogShown) {
          _showDialog(context);
        } else if (!state.isScanning && _dialogShown) {
          _dismissDialog(context);

          // Latch the meal and error into local state the first time
          // they arrive — after this, cubit re-emits can't wipe them.
          if (state.scannedMeal != null || state.error != null) {
            setState(() {
              _meal = state.scannedMeal;
              _error = state.error;
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.kScaffold,
          appBar: AppBar(
            backgroundColor: AppColors.kScaffold,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Error — use local _error, not state.error
                if (_error != null) ...[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Retake'),
                        ),
                      ],
                    ),
                  ),

                  // Result — use local _meal, not state.scannedMeal
                ] else if (_meal != null) ...[
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        widget.imageFile,
                        height: 160,
                        width: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _meal!.name.capitalizeFirst(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  30.kH,
                  Text(
                    _meal!.calories.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8C00),
                      height: 1,
                    ),
                  ),
                  const Text(
                    'calories',
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 30),
                  _FoodMacros(meal: _meal!),
                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FoodMacros extends StatelessWidget {
  final FoodItem meal;
  const _FoodMacros({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pagePadding,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.kgrey.withValues(alpha: 0.3)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _MacroItem(
                value: '${meal.protein.toInt()}g',
                label: 'Protein',
                color: const Color(0xFF4A90D9),
              ),
              _Divider(),
              _MacroItem(
                value: '${meal.carbs.toInt()}g',
                label: 'Carbs',
                color: const Color(0xFFF5A623),
              ),
              _Divider(),
              _MacroItem(
                value: '${meal.fat.toInt()}g',
                label: 'Fat',
                color: const Color(0xFFE05C5C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MacroItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: double.infinity,
      color: Colors.grey[300],
    );
  }
}
