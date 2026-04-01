import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';

class BodyIqScreen extends StatelessWidget {
  const BodyIqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppPaddings.backgroundPAll,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Icon(Icons.self_improvement, size: 80, color: AppColors.kPrimaryColor),
                    AppSize.kHeight20,

                    // Title
                    Text('BodyIQ', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48)),
                    AppSize.kHeight10,

                    Text(
                      'Ayurvedic Wellness Game',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    AppSize.kHeight40,

                    // Info Card
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.kWhite.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🎮 Lunch Break Wellness Challenge',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          AppSize.kHeight15,
                          ...[
                            '✨ Discover your Ayurvedic itution',
                            '🎯 Get personalized wellness recommendations',
                            '📊 Track your progress with coworkers',
                            '🏆 No downloads or accounts needed',
                          ].map(
                            (text) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSize.kHeight40,

                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      child: ButtonWidget(
                        text: "Start Your Wellness Journey",
                        borderRadius: BorderRadius.circular(15),
                        backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                        onPressed: () {
                          bodyIqProvider.navigateToAssessment(context);
                        },
                      ),
                    ),
                    AppSize.kHeight15,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
