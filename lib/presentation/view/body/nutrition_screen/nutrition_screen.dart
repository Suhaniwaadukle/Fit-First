// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/view/body/Partners/partners_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionScreen extends StatefulWidget {
  final String activityId;
  final String activityType;

  const NutritionScreen({
    super.key,
    required this.activityId,
    required this.activityType,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Nutrition',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: BlocBuilder<ActivitySubCategoryBloc, ActivitySubCategoryState>(
        builder: (context, state) {
          if (state is ActivitySubCategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActivitySubCategoryLoaded) {
            final subCategories = state.subCategories;
            if (subCategories.isEmpty) {
              return const Center(
                child: Text(
                  'No nutrition available for this activity',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            final subCategoryList = subCategories.first.activitySubCategory;
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: GridView.builder(
                  itemCount: subCategoryList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  padding: const EdgeInsets.all(24),
                  itemBuilder: (context, index) {
                    final subCat = subCategoryList[index];
                    return InkWell(
                      onTap: () async {
                        final sharedPreferences = await SharedPreferences.getInstance();
                        final userId = sharedPreferences.getString('userId') ?? '';
                        CustomSmoothNavigator.push(
                          context,
                          PartnersScreen(
                            userId: userId,
                            subcategoryId: subCat.id,
                          ),
                        );
                      },
                      child: CommonContainerWithBorder(
                        radius: 10,
                        child: Column(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              subCat.icon,
                              height: 35,
                              width: 35,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                            ),
                            Text(
                              subCat.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (state is ActivitySubCategoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
