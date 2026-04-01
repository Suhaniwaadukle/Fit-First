import 'package:flutter/material.dart';
import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';
import 'package:orka_sports/presentation/view/gym/presentation/widgets/selectable_grid.dart';

class ExperienceLevelScreen extends StatelessWidget {
  const ExperienceLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectableGridScreen(
      appbarTitle: 'Experience Level',
      title: 'Select your fitness experience',
      items: [
        SelectableTileItem(
          title: 'Beginner',
          description: 'Just getting started',
          icon: Icons.star_border,
          color: AppColors.kPrimaryColor,
          category: "Experience Level",
        ),
        SelectableTileItem(
          title: 'Intermediate',
          description: 'Working out regularly',
          icon: Icons.star_half,
          color: AppColors.kPrimaryColor,
          category: "Experience Level",
        ),
        SelectableTileItem(
          title: 'Advanced',
          description: 'Fitness is a lifestyle',
          icon: Icons.star,
          color: AppColors.kPrimaryColor,
          category: "Experience Level",
        ),
      ],
      onContinue: (selected) {
        NavigationWidget.commonNavigation(
          context: context,
          route: AppRoutesConstants.communication,
        );
      },
    );
  }
}
