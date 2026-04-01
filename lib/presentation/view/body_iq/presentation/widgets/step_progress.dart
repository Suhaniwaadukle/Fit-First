import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';

class StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgress({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step $currentStep of $totalSteps',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.kBlack.withValues(alpha: 0.4)),
        ),
        AppSize.kWidth10,
        Container(
          width: 80,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.kBlack.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(color: AppColors.kPrimaryColor, borderRadius: BorderRadius.circular(3)),
            ),
          ),
        ),
      ],
    );
  }
}
