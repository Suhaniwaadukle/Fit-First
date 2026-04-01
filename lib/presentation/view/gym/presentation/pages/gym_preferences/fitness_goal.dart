import 'package:flutter/material.dart';
import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';
import 'package:orka_sports/presentation/view/gym/presentation/widgets/selectable_grid.dart';

class FitnessGoalsScreen extends StatelessWidget {
  const FitnessGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectableGridScreen(
      appbarTitle: 'Fitness goal',
      title: 'What are your fitness goals?',
      items: [
        SelectableTileItem(
          title: 'Weight Loss',
          description: 'Lose weight and get lean',
          icon: Icons.trending_down,
          color: AppColors.kPrimaryColor,
          category: "Fitness goal",
        ),
        SelectableTileItem(
          title: 'Muscle Gain',
          description: 'Build muscle and strength',
          icon: Icons.fitness_center,
          color: AppColors.kPrimaryColor,
          category: "Fitness goal",
        ),
        SelectableTileItem(
          title: 'General Fitness',
          description: 'Stay healthy and active',
          icon: Icons.favorite,
          color: AppColors.kPrimaryColor,
          category: "Fitness goal",
        ),
        SelectableTileItem(
          title: 'Stay Consistent',
          description: 'Build a workout routine',
          icon: Icons.schedule,
          color: AppColors.kPrimaryColor,
          category: "Fitness goal",
        ),
      ],
      onContinue: (selectedItems) {
        NavigationWidget.commonNavigation(
          context: context,
          route: AppRoutesConstants.expLevel,
        );
      },
    );
  }
}
