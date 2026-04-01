import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/body_iq/domain/entities/body_iq_entity.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/dosha_quiz/dosha_quiz_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/lifestyle_quiz/lifestyle_quiz_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/risk_quiz/risk_quiz_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/user_profile/user_profile_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/widgets/step_progress.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
        // final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);

        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: AppColors.kWhite,
            title: Row(
              children: [
                Icon(Icons.eco, color: AppColors.kPrimaryColor),
                SizedBox(width: 8),
                Text('BodyIQ', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: StepProgress(currentStep: bodyIqState.currentStep, totalSteps: 9),
              ),
            ],
          ),
          body: _buildCurrentStep(bodyIqState),
        );
      },
    );
  }

  Widget _buildCurrentStep(BodyIqEntity appState) {
    switch (appState.currentStep) {
      case 1:
        return const UserProfileScreen();
      case 2:
        return const DoshaQuizScreen();
      case 3:
        return const LifestyleQuizScreen();
      case 4:
        return const RiskQuizScreen();
      default:
        return const UserProfileScreen();
    }
  }
}
