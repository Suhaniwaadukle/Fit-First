import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/view/body/gear_screen/gear_screen.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_diet_tracking_screen.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_personalized_plan_screen.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_progress_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_today_workout_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/domain/entities/scheduler_entity.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/presentation/controllers/scheduler_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GymDashboardScreen extends StatefulWidget {
  const GymDashboardScreen({super.key});


  @override
  State<GymDashboardScreen> createState() => _GymDashboardScreenState();
}


class _GymDashboardScreenState extends State<GymDashboardScreen> {
  String? partnerId; // ✅ ADD THIS STATE VARIABLE


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) async {
        final schedulerController = ProviderScope.containerOf(context).read(DiProviders.schedulerControllerProvider.notifier);
        final gymController = ProviderScope.containerOf(context).read(DiProviders.gymControllerProvider.notifier);


        await gymController.checkGymVerificationStatus();
        schedulerController.startGreetingTimer();
        schedulerController.getWeeklyProgress(context);
        schedulerController.getTodayWorkOutSchedule(context);
        final prefs = await SharedPreferences.getInstance();
        final storedPartnerId = prefs.getString("partnerId");

        setState(() {
          partnerId = storedPartnerId; // ✅ STORE IN STATE
        });

        print("Partner ID found: $storedPartnerId"); // ✅ DEBUG LOG

        if (storedPartnerId != null && storedPartnerId.isNotEmpty) {
          print("Loading gym buddies for partner: $storedPartnerId"); // ✅ DEBUG LOG
          gymController.getGymBuddy(context);
        } else {
          print("No partner ID found - user needs to select a gym"); // ✅ DEBUG LOG
        }
      },
    );
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final schedulerState = ref.watch(DiProviders.schedulerControllerProvider);
        final schedulerProvider = ref.read(DiProviders.schedulerControllerProvider.notifier);
        final weeklyProgress = schedulerState.getWeeklyProgressList.progress;
        final todayWorkOut = schedulerState.getTodayWorkOutList.data;


        return schedulerState.isWeeklyProgressLoading || schedulerState.isTodayWorkOutLoading
            ? CommonLoadingWidget()
            : weeklyProgress == null && todayWorkOut == null
            ? GymBoardingScreen()
            : GymResultScreen(
          schedulerState: schedulerState,
          weeklyProgress: weeklyProgress,
          todayWorkOut: todayWorkOut,
          schedulerController: schedulerProvider,
          partnerId: partnerId,
        );
      },
    );
  }
}


class GymResultScreen extends ConsumerWidget {
  const GymResultScreen({
    super.key,
    required this.schedulerState,
    required this.weeklyProgress,
    required this.todayWorkOut,
    required this.schedulerController,
    required this.partnerId, // ✅ CHANGE THIS
  });


  final SchedulerEntity schedulerState;
  final Progress? weeklyProgress;
  final TodayWorkoutData? todayWorkOut;
  final SchedulerController schedulerController;
  final String? partnerId;

  String formatTimeTo12Hour(String time24) {
    try {
      final DateTime dateTime = DateTime.parse('2023-01-01 $time24:00');
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return time24; // fallback
    }
  }

  Widget _buildSelectGymContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Colors.grey, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Select Your Gym", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text("Choose a gym to find workout buddies", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              CustomSmoothNavigator.push(context, GymBoardingScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Select Gym"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildNoBuddiesContainer(BuildContext context, gymProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("No gym buddies available", style: TextStyle(fontWeight: FontWeight.w600)),
                Text("Be the first to join this gym!", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              gymProvider.getGymBuddy(context); // Retry loading
            },
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBuddyList(gymState, BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: gymState.getGymBuddyList.data?.length ?? 0,
        itemBuilder: (context, index) {
          final buddy = gymState.getGymBuddyList.data?[index];
          final rating = double.tryParse(buddy?.avgRating ?? '0') ?? 0.0;

          return Container(
            width: 200, // Shows ~3 at a time
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                // Buddy Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundImage: (buddy?.image != null && buddy!.image!.isNotEmpty)
                      ? NetworkImage(buddy.image!)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: (buddy?.image == null || buddy!.image!.isEmpty)
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
                ),

                const SizedBox(width: 12),

                // Buddy Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name
                      Text(
                        buddy?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Age ${buddy?.age ?? '-'} • ${buddy?.fitnessLevel ?? 'Beginner'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: rating >= 4.0 ? Colors.green :
                            rating >= 3.0 ? Colors.orange :
                            rating >= 1.0 ? Colors.red : Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating > 0 ? rating.toStringAsFixed(1) : 'New',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: rating >= 4.0 ? Colors.green :
                              rating >= 3.0 ? Colors.orange :
                              rating >= 1.0 ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () {
            return schedulerController.onRefreshGymSchedule(context);
          },
          child: SingleChildScrollView(
            padding: AppPaddings.backgroundPAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(schedulerState.greetingMessage, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text("Ready for today's workout?", style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                schedulerState.isWeeklyProgressLoading || schedulerState.isTodayWorkOutLoading
                    ? CommonLoadingWidget()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekly Progress
                    Text("Weekly Progress",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
                    AppSize.kHeight15,
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.kWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(
                              value: double.parse(weeklyProgress?.percentage ?? "0") / 100,
                              color: AppColors.kPrimaryColor,
                              backgroundColor: Colors.grey.shade300,
                              strokeWidth: 6,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                              "${weeklyProgress?.completedDays} of ${weeklyProgress?.totalDays} workouts completed",
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),

                    AppSize.kHeight15,
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<ActivitySubCategoryBloc>().add(
                                LoadSubCategories(activityId: "28", activityType: 'Nutrition'),
                              );
                              CustomSmoothNavigator.push(
                                context,
                                NutritionScreen(activityId: "28", activityType: 'Nutrition'),
                              );
                            },
                            icon: const Icon(Icons.restaurant_menu, color: Colors.white),
                            label: const Text('Nutrition',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<ActivitySubCategoryBloc>().add(
                                LoadSubCategories(activityId: "28", activityType: 'Gear'),
                              );
                              CustomSmoothNavigator.push(
                                context,
                                GearScreen(activityId: "28", activityType: 'Gear'),
                              );
                            },
                            icon: const Icon(Icons.sports_martial_arts, color: Colors.white),
                            label:
                            const Text('Gears', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text("Workout Progress",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
                    AppSize.kHeight15,
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: todayWorkOut?.workout == "Off today"
                          ? Text("Off Day - No workout scheduled for today")
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Workout", style: TextStyle(color: AppColors.kWhite)),
                          const SizedBox(height: 6),
                          Text(todayWorkOut?.workout ?? '',
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                  "${formatTimeTo12Hour(todayWorkOut?.workoutTimeFrom ?? '')} - ${formatTimeTo12Hour(todayWorkOut?.workoutTimeTo ?? '')}",
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white),
                              const SizedBox(width: 4),
                              Text("with ${todayWorkOut?.buddyName ?? ''}",
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ButtonWidget(
                              text: "Mark as Complete",
                              borderRadius: BorderRadius.circular(15),
                              backgroundColor: WidgetStatePropertyAll(AppColors.kWhite),
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: AppColors.kPrimaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              onPressed: () async {
                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: CircularProgressIndicator(color: AppColors.kPrimaryColor),
                                    ),
                                  );


                                  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                                  if (!serviceEnabled) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Location services are disabled.'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }


                                  LocationPermission permission = await Geolocator.checkPermission();
                                  if (permission == LocationPermission.denied) {
                                    permission = await Geolocator.requestPermission();
                                    if (permission == LocationPermission.denied) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Location permissions are denied.'), backgroundColor: Colors.red),
                                      );
                                      return;
                                    }
                                  }
                                  if (permission == LocationPermission.deniedForever) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Location permissions are permanently denied.'), backgroundColor: Colors.red),
                                    );
                                    return;
                                  }


                                  Position position = await Geolocator.getCurrentPosition();


                                  final prefs = await SharedPreferences.getInstance();
                                  final String? userIdStr = prefs.getString("userId");
                                  if (userIdStr == null) {
                                    Navigator.pop(context);
                                    throw Exception("User ID not found.");
                                  }
                                  int userId = int.tryParse(userIdStr) ?? 0;


                                  String currentDay = DateFormat('EEEE').format(DateTime.now());


                                  final data = {
                                    "user_id": userId,
                                    "day": currentDay,
                                    "latitude": position.latitude,
                                    "longitude": position.longitude,
                                  };


                                  print("Mark complete request: $data");


                                  final response = await Dio().post(
                                    "https://fitfirst.online/Api/markWorkoutComplete",
                                    data: data,
                                  );


                                  Navigator.pop(context);


                                  final respData = response.data;
                                  if (respData["status"] == "success") {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${respData["message"]} 🎉 Coins awarded: ${respData["coins_awarded_today"]}"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );

                                    schedulerController.onRefreshGymSchedule(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(respData["message"] ?? "Failed to mark workout complete"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error marking workout complete: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text("Workout Buddies",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
                    AppSize.kHeight15,
                    partnerId == null || partnerId!.isEmpty
                        ? _buildSelectGymContainer(context)
                        : Consumer(
                      builder: (context, ref, child) {
                        final gymState = ref.watch(DiProviders.gymControllerProvider);
                        final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);

                        print("Gym state loading: ${gymState.isGymBuddyLoading}"); // ✅ DEBUG LOG
                        print("Gym buddies count: ${gymState.getGymBuddyList.data?.length ?? 0}"); // ✅ DEBUG LOG

                        if (gymState.isGymBuddyLoading) {
                          return _buildLoadingContainer();
                        }

                        if (gymState.getGymBuddyList.data?.isEmpty ?? true) {
                          return _buildNoBuddiesContainer(context, gymProvider);
                        }

                        return _buildHorizontalBuddyList(gymState, context);
                      },
                    ),

                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final gymState = ref.watch(DiProviders.gymControllerProvider);

                        print("🔍 DEBUG: isGymCodeVerified = ${gymState.isGymCodeVerified}");

                        // Show locked state if not verified
                        if (!gymState.isGymCodeVerified) {
                          print("🔒 Showing locked state");
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.lock, color: Colors.grey[600], size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  "Complete Gym Registration",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Join a gym first to unlock your personalized plan",
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        print("✅ Showing active button");

                        return SizedBox(
                          width: double.infinity,
                          child: ButtonWidget(
                            text: "Get My Personalised Plan",
                            borderRadius: BorderRadius.circular(15),
                            backgroundColor: WidgetStatePropertyAll(AppColors.kWhite),
                            side: BorderSide(color: AppColors.kPrimaryColor),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.kPrimaryColor,
                                fontWeight: FontWeight.bold
                            ),
                            onPressed: () async {
                              print("✅ Button clicked! Starting personalised plan process...");

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => Center(
                                  child: CircularProgressIndicator(color: AppColors.kPrimaryColor),
                                ),
                              );

                              try {
                                final prefs = await SharedPreferences.getInstance();
                                final String userId = prefs.getString("userId") ?? "";

                                print("User ID: $userId");

                                if (userId.isEmpty) {
                                  throw Exception("User not logged in");
                                }

                                String doshaResult = "vata";

                                final bodyIqState = ref.read(DiProviders.bodyIqControllerProvider);
                                final doshaResultModel = bodyIqState.getDoshaResultModel;

                                if (doshaResultModel?.dominantDosha != null) {
                                  doshaResult = doshaResultModel!.dominantDosha!.toLowerCase();
                                  print("Dosha retrieved from model: $doshaResult");
                                } else {
                                  print("Using fallback dosha value: $doshaResult");
                                }

                                Navigator.pop(context);

                                print("✅ Navigating to GymPersonalizedPlanScreen...");

                                CustomSmoothNavigator.push(
                                    context,
                                    GymPersonalizedPlanScreen(
                                      userId: userId,
                                      doshaResult: doshaResult,
                                      foodType: 2,
                                    )
                                );

                              } catch (e) {
                                Navigator.pop(context);

                                print("❌ Error: $e");

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppColors.kRed,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    CommonContainerWithBorder(
                      radius: 10,
                      child: Column(
                        children: [
                          Text("Want to reset gym steps & workouts?"),
                          AppSize.kHeight10,
                          SizedBox(
                            width: double.infinity,
                            child: ButtonWidget(
                              text: "Reset Gym Steps",
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
                                CustomSmoothNavigator.push(context, GymBoardingScreen());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
