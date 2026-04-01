import 'package:flutter/material.dart';
import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';
import 'package:orka_sports/presentation/view/gym/presentation/widgets/selectable_grid.dart';

class GenderPreferenceScreen extends StatelessWidget {
  const GenderPreferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectableGridScreen(
      appbarTitle: 'Buddy Gender Preference',
      title: 'Who would you prefer to be paired with?',
      items: [
        SelectableTileItem(
          title: 'Any',
          description: 'No preference',
          icon: Icons.people_outline,
          color: AppColors.kPrimaryColor,
          category: "Buddy Gender Preference",
        ),
        SelectableTileItem(
          title: 'Same',
          description: 'Same gender as yours',
          icon: Icons.male, // or Icons.female, depending on user
          color: AppColors.kPrimaryColor,
          category: "Buddy Gender Preference",
        ),
        SelectableTileItem(
          title: 'Opposite',
          description: 'Opposite gender',
          icon: Icons.transgender,
          color: AppColors.kPrimaryColor,
          category: "Buddy Gender Preference",
        ),
      ],
      onContinue: (selectedItems) {
        NavigationWidget.commonNavigation(
          context: context,
          route: AppRoutesConstants.buddyStatus,
        );
      },
    );
  }
}
