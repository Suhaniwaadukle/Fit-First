import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_dropdowns/common_dropdowns.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/view/body/gear_screen/gear_screen.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/widgets/selectable_card.dart';

class InfoGymScreen extends StatefulWidget {
  const InfoGymScreen({super.key});

  @override
  State<InfoGymScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<InfoGymScreen> {
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
              .onInitFn(screenType: "Gym", profile: profile);
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
          appBar: CommonAppBar(
            title: "Basic info",
            titleStyle: Theme.of(context).textTheme.headlineSmall,
            actions: [
              Row(
                children: [
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll(
                        AppColors.kPrimaryColor,
                      ),
                    ),
                    onPressed: () {
                      context.read<ActivitySubCategoryBloc>().add(
                            LoadSubCategories(activityId: "28", activityType: 'Nutrition'),
                          );
                      CustomSmoothNavigator.push(
                        context,
                        NutritionScreen(activityId: "28", activityType: 'Nutrition'),
                      );
                    },
                    child: Text(
                      "Nutrition",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.kPrimaryColor,
                          ),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll(
                        AppColors.kPrimaryColor,
                      ),
                    ),
                    onPressed: () {
                      context.read<ActivitySubCategoryBloc>().add(
                            LoadSubCategories(activityId: "28", activityType: 'Gear'),
                          );
                      CustomSmoothNavigator.push(
                        context,
                        GearScreen(activityId: "28", activityType: 'Gear'),
                      );
                    },
                    child: Text(
                      "Gear",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.kPrimaryColor,
                          ),
                    ),
                  ),
                ],
              ),
              AppSize.kWidth10,
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Tell us about yourself',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We need some basic information to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field
                CommonTextFieldWithHeader(
                  label: 'Full Name',
                  textField: CustomTextFormField(
                    controller: bodyIqState.nameController,
                    hintText: 'Enter your full name',
                    preffix: Icon(
                      Icons.person_outline,
                      color: AppColors.kBlack.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    validator: (p0) {
                      return null;
                    },
                    onChanged: (val) {
                      bodyIqProvider.validateUserProfile(screenType: "Gym");
                    },
                    keyboard: TextInputType.name,
                  ),
                ),
                const SizedBox(height: 20),
                // Phone Field

                CommonTextFieldWithHeader(
                  label: 'Phone Number',
                  textField: CustomTextFormField(
                    controller: bodyIqState.phoneNumberController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    hintText: 'Enter your phone number',
                    preffix: Icon(
                      Icons.phone_outlined,
                      color: AppColors.kBlack.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    validator: (value) {
                      return null;
                    },
                    onChanged: (val) {
                      bodyIqProvider.validateUserProfile(screenType: "Gym");
                    },
                    keyboard: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 20),

                // Age and Gender Row
                Row(
                  children: [
                    Expanded(
                      child: CommonTextFieldWithHeader(
                        label: 'Age',
                        textField: CustomTextFormField(
                          controller: bodyIqState.ageController,
                          hintText: 'Age',
                          preffix: Icon(
                            Icons.cake_outlined,
                            color: AppColors.kBlack.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          validator: (p0) {
                            return null;
                          },
                          onChanged: (val) {
                            bodyIqProvider.validateUserProfile(screenType: "Gym");
                          },
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CommonTextFieldWithHeader(
                        label: "Gender",
                        textField: CommonDropDownWidget(
                          items: ['Male', 'Female', 'Other'],
                          primaryValue: bodyIqState.genderController.text,
                          hintText: "Select gender",
                          onDropDwChanged: (val) {
                            bodyIqProvider.commonDropDownChange(isGender: true, value: val ?? '', screenType: "Gym");
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                    isLoading: bodyIqState.isUserInfoLoading,
                    opacity: bodyIqState.isUserProfileValid ? 1 : 0.4,
                    text: "Continue",
                    borderRadius: BorderRadius.circular(15),
                    backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                    onPressed: bodyIqState.isUserProfileValid
                        ? () {
                            bodyIqProvider.insertUserProfile(context, screenType: "Gym");
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
