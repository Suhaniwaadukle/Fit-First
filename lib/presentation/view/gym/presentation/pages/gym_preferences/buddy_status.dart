import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';
import 'package:orka_sports/presentation/view/gym/presentation/widgets/selectable_grid.dart';

class BuddyStatusScreen extends StatelessWidget {
  const BuddyStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectableGridScreen(
      appbarTitle: 'Buddy Status',
      title: 'What\'s your current buddy availability?',
      items: [
        SelectableTileItem(
          title: 'Available',
          description: 'Looking for a workout buddy',
          icon: Icons.check_circle_outline,
          color: AppColors.kPrimaryColor,
          category: "Buddy Status",
        ),
        SelectableTileItem(
          title: 'Not Interested',
          description: 'Prefer to train solo',
          icon: Icons.cancel_outlined,
          color: AppColors.kPrimaryColor,
          category: "Buddy Status",
        ),
        SelectableTileItem(
          title: 'Already Paired',
          description: 'Already have a workout buddy',
          icon: Icons.group,
          color: AppColors.kPrimaryColor,
          category: "Buddy Status",
        ),
      ],
      onContinue: (selectedItems) {
        ProviderScope.containerOf(context).read(DiProviders.gymControllerProvider.notifier).getGoalsPref(context);
      },
    );
  }
}
