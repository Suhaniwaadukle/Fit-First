import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/view/body/Partners/partners_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GearScreen extends StatefulWidget {
  final String activityId;
  final String activityType;

  const GearScreen({
    super.key,
    required this.activityId,
    required this.activityType,
  });

  @override
  State<GearScreen> createState() => _GearScreenState();
}

class _GearScreenState extends State<GearScreen> {
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
          'Gear',
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
                  'No gear available for this activity',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            // Use the first ActivitySubCategory's subcategories (adjust as needed)
            final subCategoryList = subCategories.first.activitySubCategory;

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
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
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              spacing: 10,
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
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
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

  // Widget _buildCategoryTile({
  //   required IconData icon,
  //   required String label,
  //   required Color color,
  // }) {
  //   return InkWell(
  //     onTap: () {
  //       // TODO: Navigate to specific category screen
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(
  //           color: color.withOpacity(0.3),
  //           width: 1,
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             icon,
  //             size: 32,
  //             color: color,
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             label,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               color: color,
  //               fontWeight: FontWeight.w600,
  //               fontSize: 12,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // IconData _getIconForSubCategory(String name) {
  //   switch (name.toLowerCase()) {
  //     case 'shoes':
  //       return Icons.directions_run;
  //     case 'clothing':
  //       return Icons.checkroom;
  //     case 'accessories':
  //       return Icons.watch;
  //     case 'equipment':
  //       return Icons.fitness_center;
  //     case 'electronics':
  //       return Icons.devices;
  //     case 'safety':
  //       return Icons.security;
  //     default:
  //       return Icons.category;
  //   }
  // }

  // Color _getColorForIndex(int index) {
  //   final colors = [
  //     Colors.blue,
  //     Colors.green,
  //     Colors.purple,
  //     Colors.orange,
  //     Colors.red,
  //     Colors.teal,
  //   ];
  //   return colors[index % colors.length];
  // }
}
