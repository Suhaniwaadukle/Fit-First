import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_listview/common_listview.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/products/product_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/widgets/dosha_reco_widget.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/widgets/quiz_widgets.dart';

class PersonalizedPlanScreen extends StatefulWidget {
  const PersonalizedPlanScreen({super.key});

  @override
  State<PersonalizedPlanScreen> createState() => _PersonalizedPlanScreenState();
}

class _PersonalizedPlanScreenState extends State<PersonalizedPlanScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        ProviderScope.containerOf(context).read(DiProviders.bodyIqControllerProvider.notifier).onInitDoshaReco(context);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
        // final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);
        return Scaffold(
          appBar: CommonAppBar(),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: bodyIqState.isDoshaDietLoading ||
                      bodyIqState.isDoshaMeditationLoading ||
                      bodyIqState.isDoshaExerciseLoading
                  ? CommonLoadingWidget()
                  : Column(
                      children: [
                        // Header Card
                        QuizWidgets.buildTitleSection(
                          context,
                          title: "Your Personalized Plan",
                          subTitle: "Customized recommendations based\non your Dosha profile",
                        ),
                        AppSize.kHeight15,
                        // Content
                        Expanded(
                          child: ListView(
                            children: [
                              // Diet Recommendations
                              CommonContainerWithBorder(
                                radius: 16,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      spacing: 12,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CommonContainerWithBorder(
                                            color: AppColors.kPrimaryColor,
                                            radius: 15,
                                            child: Icon(Icons.restaurant, color: AppColors.kWhite),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 9,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Diet Recommendations',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                              ),
                                              Text(
                                                'Foods that balance your constitution',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      color: AppColors.kBlack.withValues(alpha: 0.7),
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSize.kHeight15,
                                    // Include These
                                    CommonContainerWithBorder(
                                      radius: 10,
                                      color: AppColors.kPrimaryColor.withValues(alpha: 0.05),
                                      borderColor: Colors.transparent,
                                      child: Column(
                                        spacing: 10,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.check_circle, color: AppColors.kPrimaryColor, size: 24),
                                              SizedBox(width: 8),
                                              Text(
                                                'Include These',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                          CommonListviewBuilder(
                                            separatorBuilder: (context, index) => AppSize.kHeight10,
                                            itemCount: bodyIqState.dietTitles.length,
                                            itemBuilder: (context, index) {
                                              final meals = bodyIqState.getDoshaRecoDietModel.meals;

                                              final mealLists = [
                                                meals?.breakfast ?? [],
                                                meals?.lunch ?? [],
                                                meals?.dinner ?? [],
                                              ];
                                              return MealSection(
                                                title: bodyIqState.dietTitles[index],
                                                meals: mealLists[index],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppSize.kHeight10,
                                  ],
                                ),
                              ),
                              AppSize.kHeight15,

                              // Exercise Plan
                              CommonContainerWithBorder(
                                radius: 16,
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      spacing: 12,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CommonContainerWithBorder(
                                            color: AppColors.kPrimaryColor,
                                            radius: 15,
                                            child: Icon(Icons.directions_run, color: AppColors.kWhite),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 9,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Exercise Plan',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                              ),
                                              Text(
                                                'Activities that suit your energy type',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      color: AppColors.kBlack.withValues(alpha: 0.7),
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSize.kHeight15,
                                    CommonListviewBuilder(
                                      separatorBuilder: (context, index) => AppSize.kHeight10,
                                      itemCount: bodyIqState.getDoshaRecoExerciseModel.meditation?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final meditation = bodyIqState.getDoshaRecoExerciseModel.meditation ?? [];
                                        return ExerciseItemSection(
                                          type: "Exercise",
                                          plan: meditation[index].exercisePlan ?? "",
                                        );
                                      },
                                    ),
                                    AppSize.kHeight15,
                                    SizedBox(
                                      width: double.infinity,
                                      child: ButtonWidget(
                                        text: "Find Yoga Center (near you)",
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(color: AppColors.kPrimaryColor),
                                        backgroundColor: WidgetStatePropertyAll(AppColors.kWhite),
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: AppColors.kPrimaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        onPressed: () {
                                          // bodyIqProvider.nextStep();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSize.kHeight15,

                              // Meditation Practice
                              CommonContainerWithBorder(
                                radius: 16,
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      spacing: 12,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: CommonContainerWithBorder(
                                            color: AppColors.kPrimaryColor,
                                            radius: 15,
                                            child: Icon(Icons.self_improvement, color: AppColors.kWhite),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 9,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Meditation Practice',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                              ),
                                              Text(
                                                'Mindfulness techniques for your dosha',
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      color: AppColors.kBlack.withValues(alpha: 0.7),
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppSize.kHeight15,
                                    CommonListviewBuilder(
                                      separatorBuilder: (context, index) => AppSize.kHeight10,
                                      itemCount: bodyIqState.getDoshaRecoMeditationModel.meditation?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final meditation = bodyIqState.getDoshaRecoMeditationModel.meditation ?? [];
                                        return ExerciseItemSection(
                                          type: "Meditation",
                                          plan: meditation[index].meditationTechnique ?? "",
                                        );
                                      },
                                    ),
                                    AppSize.kHeight8,
                                    CommonContainerWithBorder(
                                      radius: 10,
                                      color: AppColors.kWhite,
                                      child: Text(
                                        'Practice grounding meditation techniques that help calm your active mind and bring awareness to your body.',
                                      ),
                                    ),
                                    AppSize.kHeight10,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        AppSize.kHeight15,
                        // Button
                        SizedBox(
                          width: double.infinity,
                          child: ButtonWidget(
                            text: "View Product Recommendations",
                            borderRadius: BorderRadius.circular(15),
                            backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                            onPressed: () {
                              CustomSmoothNavigator.push(context, ProductScreenBodyIq());
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
