import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/dosha_models/get_dosha_diet_model.dart';

class MealSection extends StatelessWidget {
  final String title;
  final List<Breakfast> meals;

  const MealSection({super.key, required this.title, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...meals.map(
          (meal) => BulletItem(
            text: meal.dish ?? '',
            isVeg: meal.isVeg ?? true,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class BulletItem extends StatelessWidget {
  final String text;
  final bool isVeg;

  const BulletItem({super.key, required this.text, required this.isVeg});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isVeg ? Icons.circle : Icons.circle_outlined,
                    color: isVeg ? AppColors.kGreen : AppColors.kRed,
                    size: 10,
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSize.kHeight10,
      ],
    );
  }
}

class ExerciseItemSection extends StatelessWidget {
  final String plan;
  final String type;
  const ExerciseItemSection({super.key, required this.plan, required this.type});

  @override
  Widget build(BuildContext context) {
    return CommonContainerWithBorder(
      radius: 10,
      color: AppColors.kPrimaryColor.withValues(alpha: 0.05),
      borderColor: Colors.transparent,
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(type == "Exercise" ? Icons.fitness_center : Icons.spa, color: AppColors.kPrimaryColor, size: 20),
          Expanded(
            child: Text(
              plan,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
