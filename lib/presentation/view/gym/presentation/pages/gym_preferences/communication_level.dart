import 'package:flutter/material.dart';
import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';
import 'package:orka_sports/presentation/view/gym/presentation/widgets/selectable_grid.dart';

class CommunicationStyleScreen extends StatelessWidget {
  const CommunicationStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectableGridScreen(
      appbarTitle: 'Communication Style',
      title: 'How do you prefer to communicate during workouts?',
      items: [
        SelectableTileItem(
          title: 'Talkative',
          description: 'Enjoy chatting while working out',
          icon: Icons.chat_bubble_outline,
          color: AppColors.kPrimaryColor,
          category: "Communication Style",
        ),
        SelectableTileItem(
          title: 'Focused',
          description: 'Prefer to stay in the zone',
          icon: Icons.center_focus_strong,
          color: AppColors.kPrimaryColor,
          category: "Communication Style",
        ),
        SelectableTileItem(
          title: 'Motivator',
          description: 'Like encouraging and pushing others',
          icon: Icons.emoji_events,
          color: AppColors.kPrimaryColor,
          category: "Communication Style",
        ),
      ],
      onContinue: (selectedItems) {
        NavigationWidget.commonNavigation(
          context: context,
          route: AppRoutesConstants.budyyGender,
        );
      },
    );
  }
}
