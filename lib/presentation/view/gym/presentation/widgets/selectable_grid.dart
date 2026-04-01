import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/view/body/gear_screen/gear_screen.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';

class SelectableGridScreen extends StatefulWidget {
  final String title;
  final String appbarTitle;
  final List<SelectableTileItem> items;
  final void Function(List<SelectableTileItem>) onContinue;

  const SelectableGridScreen({
    super.key,
    required this.title,
    required this.items,
    required this.onContinue,
    required this.appbarTitle,
  });

  @override
  State<SelectableGridScreen> createState() => _SelectableGridScreenState();
}

class _SelectableGridScreenState extends State<SelectableGridScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final gymState = ref.watch(DiProviders.gymControllerProvider);
      final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);
      return Scaffold(
        appBar: CommonAppBar(
          title: widget.appbarTitle,
          titleStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          actions: [
            Row(
              children: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(
                      AppColors.kPrimaryColor,
                    ),
                  ),
                  onPressed: () {
                    context.read<ActivitySubCategoryBloc>().add(
                          LoadSubCategories(activityId: "28", activityType: 'Nutrition'),
                        );
                    CustomSmoothNavigator.push(
                      context,
                      NutritionScreen(activityId: "28", activityType: 'Nutrition'),
                    );
                  },
                  child: Text(
                    "Nutrition",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.kPrimaryColor,
                        ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(
                      AppColors.kPrimaryColor,
                    ),
                  ),
                  onPressed: () {
                    context.read<ActivitySubCategoryBloc>().add(
                          LoadSubCategories(activityId: "28", activityType: 'Gear'),
                        );
                    CustomSmoothNavigator.push(
                      context,
                      GearScreen(activityId: "28", activityType: 'Gear'),
                    );
                  },
                  child: Text(
                    "Gear",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.kPrimaryColor,
                        ),
                  ),
                ),
              ],
            ),
            AppSize.kWidth10,
          ],
        ),
        body: Padding(
          padding: AppPaddings.backgroundPAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold)),
              AppSize.kHeight30,
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = gymState.selectedItems.any(
                        (selectedItem) => selectedItem.category == item.category && selectedItem.title == item.title);

                    return GestureDetector(
                      onTap: () {
                        gymProvider.toggleGridSelection(item);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? item.color : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? item.color : AppColors.kBlack.withValues(alpha: 0.1),
                            width: 0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isSelected ? item.color.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : item.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(item.icon, size: 30, color: isSelected ? Colors.white : item.color),
                              ),
                              AppSize.kHeight15,
                              Text(
                                item.title,
                                style: isSelected
                                    ? Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)
                                    : Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              AppSize.kHeight8,
                              Text(
                                item.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.9)
                                          : Theme.of(context).hintColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              AppSize.kHeight10,
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check, size: 16, color: item.color),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              AppSize.kHeight20,
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: AppPaddings.bottomnavP,
          child: SizedBox(
            width: double.infinity,
            child: ButtonWidget(
              isLoading: gymState.isPreferrencesLoading,
              borderRadius: BorderRadius.circular(15),
              text: 'Continue',
              backgroundColor: gymState.selectedItems.any((item) => item.category == widget.appbarTitle)
                  ? WidgetStatePropertyAll(AppColors.kPrimaryColor)
                  : WidgetStatePropertyAll(AppColors.kBlack.withValues(alpha: 0.15)),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.kWhite,
                    fontWeight: FontWeight.bold,
                  ),
              onPressed: gymState.selectedItems.any((item) => item.category == widget.appbarTitle)
                  ? () {
                      final selected =
                          gymState.selectedItems.where((item) => item.category == widget.appbarTitle).toList();
                      widget.onContinue(selected);
                    }
                  : null,
            ),
          ),
        ),
      );
    });
  }
}
