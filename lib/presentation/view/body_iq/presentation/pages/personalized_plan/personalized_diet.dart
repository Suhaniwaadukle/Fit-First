import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/personalized_plan/add_diet_screen.dart';

class PersonalizedDietScreen extends StatelessWidget {
  final int targetKcal = 200;
  final int consumedKcal = 0;

  const PersonalizedDietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int remainingKcal = targetKcal - consumedKcal;

    return Scaffold(
      appBar: CommonAppBar(
        title: "Personalized Diet Plan",
        titleStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 of 200 Kcal', style: TextStyle(fontSize: 16)),
                Text('Remaining : $remainingKcal Kcal', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade400),
          AppSize.kHeight15,
          MealTile(title: "Breakfast"),
          MealTile(title: "Lunch"),
          MealTile(title: "Snack"),
          MealTile(title: "Dinner"),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: AppPaddings.bottomnavP,
        child: SizedBox(
          width: double.infinity,
          child: ButtonWidget(
            text: "View Progress Tracking",
            borderRadius: BorderRadius.circular(15),
            backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
            onPressed: () {
              // CustomSmoothNavigator.push(context, ProgressTrackerScreen());
            },
          ),
        ),
      ),
    );
  }
}

class MealTile extends StatelessWidget {
  final String title;
  const MealTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$title (0Kcal)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                CustomSmoothNavigator.push(
                  context,
                  AddDietScreen(),
                );
              },
              label: Text(
                "Add",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              icon: Icon(
                Icons.add_circle_outline,
                size: AppSize.appIconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodItem {
  final String name;
  final int quantity;
  final int kcal;

  FoodItem({required this.name, required this.quantity, required this.kcal});
}
