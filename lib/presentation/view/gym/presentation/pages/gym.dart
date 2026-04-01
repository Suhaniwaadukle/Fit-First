import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';

class GymBoardingScreen extends StatefulWidget {
  const GymBoardingScreen({super.key});

  @override
  State<GymBoardingScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<GymBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer(builder: (context, ref, child) {
      final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Gym Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: AppColors.kWhite,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Welcome Title
                    Text(
                      'Welcome to\nGym Experience',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Join the future of fitness with gym partners & gym buddies.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.kBlack..withValues(alpha: 0.9),
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sign In Text
                    SizedBox(
                      width: double.infinity,
                      child: ButtonWidget(
                        borderRadius: BorderRadius.circular(15),
                        text: 'Get Started',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                              color: AppColors.kWhite,
                              fontWeight: FontWeight.bold,
                            ),
                        onPressed: () {
                          gymProvider.toInfoScreenGym(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
