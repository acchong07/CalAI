import 'package:cal_scanner/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgeWidget extends StatelessWidget {
  const AgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null) {
              context.read<OnboardingCubit>().updateAge(parsed);
            }
          },
          decoration: InputDecoration(labelText: 'Age in years'),
        ),
      ],
    );
  }
}
