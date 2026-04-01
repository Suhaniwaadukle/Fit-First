import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/core/services/di_services.dart'; // Add this import
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/add_bodyiq_exercise_schedule_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/diet_tracking/diet_tracking_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/products/product_screen.dart'; // Add this import
import 'package:orka_sports/presentation/view/gym/presentation/pages/add_exercise_schedule_screen.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/add_supplement_schedule_screen.dart';

class bodyiqPersonalizedPlanScreen extends ConsumerWidget {
  final String userId;
  final String doshaResult;
  final int foodType;

  const bodyiqPersonalizedPlanScreen({
    super.key,
    required this.userId,
    required this.doshaResult,
    required this.foodType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void _navigateTo(BuildContext context, Widget screen) {
      CustomSmoothNavigator.push(context, screen);
    }

    Widget planBox(String title, String subtitle, IconData icon, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.kWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.kPrimaryColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.kPrimaryColor, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_forward_ios, 
                  color: AppColors.kPrimaryColor, 
                  size: 16
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Personalized Plan",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.backgroundPAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.kPrimaryColor.withOpacity(0.1),
                    AppColors.kPrimaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: AppColors.kPrimaryColor, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        "Your Dosha: ${doshaResult.toUpperCase()}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Create your personalized fitness journey based on your unique body type and wellness goals.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Section Title
            Text(
              "Choose Your Plan",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Select the area you want to focus on",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Plan Options
            planBox(
              "BodyIQ Meal Plan",
              "Personalized nutrition based on your dosha type",
              Icons.restaurant_menu,
              () => _navigateTo(
                context, 
                DietTrackingScreen(
                  userId: userId,
                  doshaResult: doshaResult,
                  foodType: foodType,
                )
              ),
            ),
            planBox(
              "Schedule Your Exercise",
              "Create your perfect workout schedule and routine",
              Icons.schedule,
              () => CustomSmoothNavigator.push(
                context,
                AddbodyiqExerciseScheduleScreen(
                  userId: userId,
                  doshaResult: doshaResult,
                ),
              ),
            ),
            planBox(
              "Add Your Supplement",
              "Enhance your fitness with targeted supplements",
              Icons.medical_services,
              () => CustomSmoothNavigator.push(
                context,
                AddSupplementScheduleScreen(
                  userId: userId,
                  doshaResult: doshaResult,
                ),
              ),
            ),

            // ✅ NEW: View Supplements Button
            planBox(
              "View Supplements",
              "Discover recommended supplements for your dosha type",
              Icons.medication,
              () async {
                // Call the API to load recommended products
                await ref.read(DiProviders.bodyIqControllerProvider.notifier)
                    .getRecoProducts(context);
                
                // Navigate to products screen
                CustomSmoothNavigator.push(
                  context, 
                  ProductScreenBodyIq()
                );
              },
            ),

            // Bottom Info Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: AppColors.kWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.kPrimaryColor, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    "Pro Tip",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Start with meal planning, then add exercise scheduling, and finally incorporate supplements for best results.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
