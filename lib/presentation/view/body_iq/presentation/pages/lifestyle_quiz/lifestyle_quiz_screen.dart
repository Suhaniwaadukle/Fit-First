import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/body_iq/domain/entities/body_iq_entity.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/controllers/body_iq_controller.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/widgets/quiz_widgets.dart';

class LifestyleQuizScreen extends StatefulWidget {
  const LifestyleQuizScreen({super.key});

  @override
  State<LifestyleQuizScreen> createState() => _LifestyleQuizScreenState();
}

class _LifestyleQuizScreenState extends State<LifestyleQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
        final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppColors.kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.kBlack.withAlpha(13), blurRadius: 20, offset: Offset(0, 10))],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            QuizWidgets.buildLogo(icon: Icons.trending_up),
                            AppSize.kHeight20,
                            QuizWidgets.buildTitleSection(
                              context,
                              title: "Lifestyle Assessment",
                              subTitle: "Evaluate your content wellness habits",
                            ),
                            AppSize.kHeight30,
                            buildProgressSection(bodyIqState),
                            AppSize.kHeight30,
                            buildQuestionSection(
                              bodyIqState.lifeStyleQuestions[bodyIqState.currentLifestyleQuestion],
                              bodyIqState.lifeStyleOptions[bodyIqState.currentLifestyleQuestion],
                              bodyIqState,
                              bodyIqProvider,
                            ),
                            AppSize.kHeight40,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildProgressSection(BodyIqEntity bodyIqState) {
    final current = bodyIqState.currentLifestyleQuestion;
    final total = bodyIqState.lifeStyleQuestions.length;
    final progressPercentage = ((current + 1) / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${current + 1} of $total',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.kBlack.withValues(alpha: 0.7)),
            ),
            Text(
              'Score : ${(progressPercentage * 100).round()}/100',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.kBlack.withValues(alpha: 0.7)),
            ),
          ],
        ),
        AppSize.kHeight8,
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(color: AppColors.kWhite, borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressPercentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.kPrimaryColor, AppColors.kPrimaryColor]),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildQuestionSection(
    String questionText,
    List<String> options,
    BodyIqEntity bodyIqState,
    BodyIqController bodyIqProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(questionText, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.kBlack)),
        AppSize.kHeight20,
        ...options.map(
          (option) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: buildOption(
              option,
              bodyIqState.selectedLifeStyleAnswers[bodyIqState.currentLifestyleQuestion] == option,
              () => bodyIqProvider.selectLifestyleOption(
                selectedOption: option,
                onComplete: () {
                  bodyIqProvider.insertDoshaLifestyleQuiz(
                    context,
                    screenType: "Lifestyle",
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOption(String option, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kWhite : AppColors.kWhite,
          border: Border.all(
            color: isSelected ? AppColors.kPrimaryColor : AppColors.kBlack.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.kPrimaryColor : Color(0xFFD1D5DB), width: 2),
                color: isSelected ? AppColors.kPrimaryColor : Colors.transparent,
              ),
              child: isSelected ? Icon(Icons.circle, size: 10, color: AppColors.kWhite) : null,
            ),
            SizedBox(width: 12),
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? AppColors.kPrimaryColor : Color(0xFF1E293B),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
