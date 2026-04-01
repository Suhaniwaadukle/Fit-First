import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';

class GymBuddyDetails extends StatefulWidget {
  const GymBuddyDetails({super.key});

  @override
  State<GymBuddyDetails> createState() => _GymBuddyDetailsState();
}

class _GymBuddyDetailsState extends State<GymBuddyDetails> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final gymState = ref.watch(DiProviders.gymControllerProvider);
      final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: CommonAppBar(
          title: "Gym Buddy Details",
          titleStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        body: gymState.isGymBuddyDetailsLoading
            ? CommonLoadingWidget()
            : gymState.getGymBuddyDetailsList.data == null
                ? Center(
                    child: Text(gymState.getGymBuddyDetailsList.message ?? ''),
                  )
                : RefreshIndicator.adaptive(
                    onRefresh: () {
                      return gymProvider.getGymBuddyDetails(context);
                    },
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          spacing: 24,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProfileHeader(
                              gymController: gymProvider,
                              gymEntity: gymState,
                            ),
                            FitnessGoalsSection(
                              gymController: gymProvider,
                              gymEntity: gymState,
                            ),
                            WeeklyWorkoutScheduleSection(
                              gymController: gymProvider,
                              gymEntity: gymState,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        bottomNavigationBar: Padding(
          padding: AppPaddings.bottomnavP,
          child: SizedBox(
            width: double.infinity,
            child: ButtonWidget(
              isLoading: gymState.isRequestBuddyLoading,
              borderRadius: BorderRadius.circular(15),
              text: "Sent Request",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(
                    color: AppColors.kWhite,
                    fontWeight: FontWeight.bold,
                  ),
              onPressed: () {
                gymProvider.requestGymBuddy(context);
              },
            ),
          ),
        ),
      );
    });
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.gymController,
    required this.gymEntity,
  });
  final GymController gymController;
  final GymEntity gymEntity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: gymEntity.getGymBuddyDetailsList.data?.profile?.image != null
                ? NetworkImage(gymEntity.getGymBuddyDetailsList.data!.profile!.image!)
                : null,
            backgroundColor: AppColors.accent,
            child: gymEntity.getGymBuddyDetailsList.data?.profile?.image == null
                ? const Icon(Icons.person, color: Colors.white, size: 30)
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    gymController.formatter.checkValue(
                      gymEntity.getGymBuddyDetailsList.data?.profile?.name,
                    ),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                SizedBox(height: 4),
                Text(
                  "Age: ${gymController.formatter.checkValue(
                    gymEntity.getGymBuddyDetailsList.data?.profile?.age,
                  )} - Fitness Level: ${gymController.formatter.checkValue(
                    gymEntity.getGymBuddyDetailsList.data?.profile?.fitnessLevel,
                  )}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class FitnessGoalsSection extends StatelessWidget {
  const FitnessGoalsSection({
    super.key,
    required this.gymController,
    required this.gymEntity,
  });
  final GymController gymController;
  final GymEntity gymEntity;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Fitness Goals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            PreferenceTile(
              icon: Icons.fitness_center,
              label: gymController.formatter.checkValue(
                gymEntity.getGymBuddyDetailsList.data?.profile?.fitnessGoal,
              ),
            ),
            PreferenceTile(
              icon: Icons.mic,
              label: gymController.formatter.checkValue(
                gymEntity.getGymBuddyDetailsList.data?.profile?.communicationStyle,
              ),
            ),
            PreferenceTile(
              icon: Icons.group,
              label: gymController.formatter.checkValue(
                gymEntity.getGymBuddyDetailsList.data?.profile?.genderPreferenceForBuddy,
              ),
            ),
            PreferenceTile(
              icon: Icons.work,
              label: gymController.formatter.checkValue(
                gymEntity.getGymBuddyDetailsList.data?.profile?.experienceLevel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const PreferenceTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.kPrimaryColor, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
        ],
      ),
    );
  }
}

class WeeklyWorkoutScheduleSection extends StatelessWidget {
  const WeeklyWorkoutScheduleSection({
    super.key,
    required this.gymController,
    required this.gymEntity,
  });

  final GymController gymController;
  final GymEntity gymEntity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Weekly Workout Schedule",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ListView.separated(
            padding: EdgeInsets.all(12),
            itemCount: gymEntity.getGymBuddyDetailsList.data?.weeklySchedule?.length ?? 0,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(height: 24, thickness: 0.1),
            itemBuilder: (context, index) {
              final item = gymEntity.getGymBuddyDetailsList.data?.weeklySchedule?[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gymController.formatter.checkValue(item?.day),
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                        SizedBox(height: 4),
                        Text(gymController.formatter.checkValue(item?.workout),
                            style: TextStyle(color: Color(0xFF374151))),
                        SizedBox(height: 4),
                        Text(
                            "${gymController.formatter.convertTo12HourFormat(gymController.formatter.checkValue(item?.workoutTimeFrom))} - ${gymController.formatter.convertTo12HourFormat(gymController.formatter.checkValue(item?.workoutTimeTo))}",
                            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Icon(Icons.fitness_center, color: AppColors.kPrimaryColor, size: 20),
                ],
              );
            },
          ),
        ),
        AppSize.kHeight30,
      ],
    );
  }
}
