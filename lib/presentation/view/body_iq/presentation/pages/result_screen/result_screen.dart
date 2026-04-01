import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/core/utils/user_utils.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/lifestyle_model/get_lifestyle_model.dart';
import 'package:orka_sports/presentation/view/body_iq/domain/entities/body_iq_entity.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/controllers/body_iq_controller.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/body_iq.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/bodyiq_personalized_plan_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/diet_tracking/diet_tracking_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/personalized_plan/personalized_plan_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/widgets/quiz_widgets.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
        final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: AppPaddings.backgroundPAll,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Main Content
                      Column(
                        children: [
                          // Star Icon
                          QuizWidgets.buildLogo(icon: Icons.star),
                          AppSize.kHeight20,
                          // Title and Subtitle
                          QuizWidgets.buildTitleSection(
                            context,
                            title: "Your Dosha Profile",
                            subTitle: "Discover your unique Ayurvedic constitution",
                          ),
                          AppSize.kHeight30,
                          // Primary Dosha Card
                          _buildPrimaryDoshaCard(bodyIqProvider: bodyIqProvider, bodyIqState: bodyIqState),
                          AppSize.kHeight30,
                          // Dosha Scores
                          _buildDoshaScores(bodyIqProvider: bodyIqProvider, bodyIqState: bodyIqState),
                          AppSize.kHeight30,
                          QuizWidgets.buildTitleSection(
                            context,
                            title: "Your LifeStyle Profile",
                            subTitle: "",
                          ),
                          _buildLifeStyleScoreCard(
                            result: bodyIqState.getLifeStyleResultModel,
                            bodyIqProvider: bodyIqProvider,
                            context: context,
                          ),

                          AppSize.kHeight30,
                          QuizWidgets.buildTitleSection(
                            context,
                            title: "Your Health Profile",
                            subTitle: "",
                          ),
                          _buildHealthResultCard(
                            context: context,
                            controller: bodyIqProvider,
                          ),
                          AppSize.kHeight30,
                          _buildGetPlanButton(bodyIqProvider: bodyIqProvider),

                          AppSize.kHeight15,
                          Divider(
                            color: AppColors.kBlack.withValues(alpha: 0.5),
                          ),
                          AppSize.kHeight15,
                          CommonContainerWithBorder(
                            radius: 10,
                            child: Column(
                              children: [
                                Text("Want to reset your dosha,health & lifestyle?"),
                                AppSize.kHeight10,
                                SizedBox(
                                  width: double.infinity,
                                  child: ButtonWidget(
                                    text: "Reset BodyIQ Steps",
                                    borderRadius: BorderRadius.circular(15),
                                    backgroundColor: WidgetStatePropertyAll(AppColors.kWhite),
                                    side: BorderSide(
                                      color: AppColors.kPrimaryColor,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                          color: AppColors.kPrimaryColor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                    onPressed: () {
                                      CustomSmoothNavigator.push(context, BodyIqScreen());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildPrimaryDoshaCard({required BodyIqEntity bodyIqState, required BodyIqController bodyIqProvider}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kYellowShade, width: 1),
      ),
      child: Column(
        children: [
          Text(
            bodyIqProvider.formatter.checkValue(bodyIqState.getDoshaResultModel.dominantDosha),
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.w600),
          ),
          AppSize.kHeight8,
          Text(
            'Air & Space',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.w500),
          ),
          AppSize.kHeight15,
          Text(
            'You are creative, energetic, and quick-thinking. You prefer movement and change, but may need to focus on grounding and stability.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.kWhite.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLifeStyleScoreCard({
    required GetLifeStyleResultModel result,
    required BodyIqController bodyIqProvider,
    required BuildContext context,
  }) {
    final String scoreStr = bodyIqProvider.formatter.checkValue(result.score?.toString());
    final int score = int.tryParse(scoreStr) ?? 0;
    final String label = bodyIqProvider.formatter.checkValue(result.summary?.label);
    final String range = bodyIqProvider.formatter.checkValue(result.summary?.range);

    final Color riskColor = getLifestyleColor(score);

    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(riskColor),
                  backgroundColor: riskColor.withValues(alpha: 0.3),
                ),
              ),
              Text(
                score.toString(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          AppSize.kHeight8,
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: riskColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSize.kHeight10,
          Text(
            range,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: riskColor.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthResultCard({
    required BuildContext context,
    required BodyIqController controller,
  }) {
    final scoreStr = controller.formatter.checkValue(controller.prefs.getString("score"));
    final riskLevel = controller.formatter.checkValue(controller.prefs.getString("risk_level"));
    final int score = int.tryParse(scoreStr) ?? 0;
    final Color riskColor = getRiskColor(riskLevel);

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: 0, endValue: 33, color: AppColors.kGreen),
                    GaugeRange(startValue: 34, endValue: 66, color: AppColors.kYellowShade),
                    GaugeRange(startValue: 67, endValue: 100, color: AppColors.kRed),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(value: score.toDouble(), needleColor: riskColor),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        score.toString(),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      angle: 90,
                      positionFactor: 0.5,
                    )
                  ],
                )
              ],
            ),
          ),
          Text(
            "Health Risk Level",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: riskColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSize.kHeight8,
          Text(
            riskLevel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: riskColor.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoshaScores({required BodyIqEntity bodyIqState, required BodyIqController bodyIqProvider}) {
    return Column(
      children: [
        _buildDoshaScoreItem(
          'Vata',
          'Movement & Change',
          bodyIqProvider.formatter.checkValue(bodyIqState.getDoshaResultModel.vata),
          AppColors.kOrange,
          Icons.air,
        ),
        AppSize.kHeight15,
        _buildDoshaScoreItem(
          'Pitta',
          'Transformation & Energy',
          bodyIqProvider.formatter.checkValue(bodyIqState.getDoshaResultModel.pitta),
          AppColors.kRed,
          Icons.local_fire_department,
        ),
        AppSize.kHeight15,
        _buildDoshaScoreItem(
            'Kapha',
            'Structure & Stability',
            bodyIqProvider.formatter.checkValue(bodyIqState.getDoshaResultModel.kapha),
            AppColors.kGreen,
            Icons.landscape),
      ],
    );
  }

  Widget _buildDoshaScoreItem(String name, String description, String score, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: AppColors.kWhite, size: 20),
          ),
          AppSize.kWidth15,
          // Text content
          Expanded(
            child: Column(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                Text(description, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
              ],
            ),
          ),
          // Score with progress bar
          Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(score, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: score.isEmpty ? 0 / 10 : int.parse(score) / 10,
                  child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// REPLACE YOUR EXISTING _buildGetPlanButton METHOD WITH THIS:
Widget _buildGetPlanButton({required BodyIqController bodyIqProvider}) {
  return SizedBox(
    width: double.infinity,
    child: ButtonWidget(
      text: "Get My Personalized Plan",
      borderRadius: BorderRadius.circular(15),
      backgroundColor: WidgetStatePropertyAll(AppColors.kWhite),
      side: BorderSide(color: AppColors.kPrimaryColor),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppColors.kPrimaryColor, 
        fontWeight: FontWeight.bold
      ),
      onPressed: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator(color: AppColors.kPrimaryColor)),
        );

        try {
          final realUserId = await UserUtils.getCurrentUserId();
          String realDoshaResult = "vata";
          
          final doshaResultModel = bodyIqProvider.state.getDoshaResultModel;
          if (doshaResultModel?.dominantDosha != null) {
            realDoshaResult = doshaResultModel!.dominantDosha!.toLowerCase();
          }
          
          Navigator.pop(context);
          
          CustomSmoothNavigator.push(
            context, 
            bodyiqPersonalizedPlanScreen(
              userId: realUserId,
              doshaResult: realDoshaResult,
              foodType: 2,
            )
          );
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.kRed),
          );
        }
      },
    ),
  );
}
}

Color getRiskColor(String riskLevel) {
  switch (riskLevel.toLowerCase()) {
    case 'low':
      return AppColors.kGreen;
    case 'medium':
      return AppColors.kYellowShade;
    case 'high':
    case 'good':
      return AppColors.kRed;
    case '':
    default:
      return AppColors.kPrimaryColor;
  }
}

Color getLifestyleColor(int score) {
  if (score <= 39) {
    return AppColors.kRed;
  } else if (score <= 69) {
    return AppColors.kYellowShade;
  } else {
    return AppColors.kGreen;
  }
}
