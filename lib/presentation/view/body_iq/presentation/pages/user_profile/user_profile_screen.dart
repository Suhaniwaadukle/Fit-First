import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_dropdowns/common_dropdowns.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/widgets/selectable_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final bloc = context.read<ProfileBloc>();
        final state = bloc.state;

        // Safely extract ProfileData from the state
        ProfileData? profile;

        if (state is ProfileLoaded) {
          profile = state.profile;
        } else if (state is ProfileUpdated) {
          profile = state.profile;
        } else if (state is ProfileUpdating) {
          profile = state.profile;
        }

        if (profile != null) {
          ProviderScope.containerOf(context)
              .read(DiProviders.bodyIqControllerProvider.notifier)
              .onInitFn(screenType: "BodyIQ", profile: profile);
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
        final bodyIqProvider = ref.watch(DiProviders.bodyIqControllerProvider.notifier);
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: AppPaddings.backgroundPAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 56, color: AppColors.kPrimaryColor),
                  AppSize.kHeight15,
                  Text("Let's Get to Know You", style: Theme.of(context).textTheme.displaySmall),
                  AppSize.kHeight8,
                  Text(
                    "Help us personalize your wellness journey",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: AppColors.kBlack.withValues(alpha: 0.5),
                        ),
                  ),
                  AppSize.kHeight20,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      CommonTextFieldWithHeader(
                        label: "Name",
                        textField: CustomTextFormField(
                          controller: bodyIqState.nameController,
                          hintText: 'Enter name',
                          validator: (val) {
                            return null;
                          },
                          keyboard: TextInputType.name,
                          onChanged: (val) {
                            bodyIqProvider.validateUserProfile(screenType: "BodyIQ");
                          },
                        ),
                      ),
                      Row(
                        spacing: 15,
                        children: [
                          Expanded(
                            child: CommonTextFieldWithHeader(
                              label: "Age",
                              textField: CustomTextFormField(
                                controller: bodyIqState.ageController,
                                hintText: 'Enter age',
                                validator: (val) {
                                  return null;
                                },
                                keyboard: TextInputType.phone,
                                onChanged: (val) {
                                  bodyIqProvider.validateUserProfile(screenType: "BodyIQ");
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: CommonTextFieldWithHeader(
                              label: "Gender",
                              textField: CommonDropDownWidget(
                                hintText: "Select gender",
                                items: bodyIqState.genderList,
                                primaryValue: bodyIqState.genderController.text,
                                onDropDwChanged: (val) {
                                  bodyIqProvider.commonDropDownChange(
                                      isGender: true, value: val ?? '', screenType: "BodyIQ");
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      CommonTextFieldWithHeader(
                        label: "Ethnicity",
                        textField: CommonDropDownWidget(
                          hintText: "Select ethnicity",
                          items: bodyIqState.ethnicityList,
                          primaryValue: bodyIqState.ethnicityController.text,
                          onDropDwChanged: (val) {
                            bodyIqProvider.commonDropDownChange(
                                isGender: false, value: val ?? '', screenType: "BodyIQ");
                          },
                        ),
                      ),
                      CommonTextFieldWithHeader(
                        label: "Height (cm)",
                        textField: CustomTextFormField(
                          hintText: 'Enter height (cm)',
                          controller: bodyIqState.heightController,
                          validator: (val) {
                            return null;
                          },
                          keyboard: TextInputType.phone,
                          onChanged: (val) {
                            bodyIqProvider.validateUserProfile(screenType: "BodyIQ");
                          },
                        ),
                      ),
                      CommonTextFieldWithHeader(
                        label: "Weight (kg)",
                        textField: CustomTextFormField(
                          hintText: 'Enter weight (kg)',
                          controller: bodyIqState.weightController,
                          validator: (val) {
                            return null;
                          },
                          keyboard: TextInputType.phone,
                          onChanged: (val) {
                            bodyIqProvider.validateUserProfile(screenType: "BodyIQ");
                          },
                        ),
                      ),
                    ],
                  ),
                  AppSize.kHeight20,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Goal *',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      AppSize.kHeight15,
                      GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: bodyIqState.goals.map((goal) {
                          return SelectableCard(
                            label: goal,
                            isSelected: bodyIqState.selectedGoal == goal,
                            onTap: () {
                              bodyIqProvider.onPrimaryGoalOnTap(value: goal);
                            },
                            icon: _getGoalIcon(goal),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  AppSize.kHeight20,
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Family History',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      AppSize.kHeight8,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: bodyIqState.familyHistory.map((history) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: bodyIqState.selectedHistory.contains(history),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  onChanged: (val) {
                                    bodyIqProvider.onFamilyHistoryOnTap(value: val ?? false, history: history);
                                  },
                                ),
                                Text(
                                  history,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.kBlack.withValues(alpha: 0.8),
                                      ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  AppSize.kHeight20,
                  SizedBox(
                    width: double.infinity,
                    child: ButtonWidget(
                      isLoading: bodyIqState.isUserInfoLoading,
                      opacity: bodyIqState.isUserProfileValid ? 1 : 0.4,
                      text: "Continue to Dosha Quiz",
                      borderRadius: BorderRadius.circular(15),
                      backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                      onPressed: bodyIqState.isUserProfileValid
                          ? () {
                              bodyIqProvider.insertUserProfile(context, screenType: "BodyIQ");
                            }
                          : null,
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

  Icon _getGoalIcon(String goal) {
    switch (goal) {
      case 'Lose Weight':
        return Icon(Icons.lock_outline, color: AppColors.kPrimaryColor);
      case 'Gain Weight':
        return Icon(Icons.scale, color: AppColors.kPrimaryColor);
      case 'Improve Digestion':
        return Icon(Icons.eco_outlined, color: AppColors.kPrimaryColor);
      case 'Balance Hormones':
        return Icon(Icons.bubble_chart, color: AppColors.kPrimaryColor);
      case 'Build Immunity':
        return Icon(Icons.shield_outlined, color: AppColors.kPrimaryColor);
      default:
        return Icon(Icons.circle_outlined);
    }
  }
}
