import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/data/models/activity_model/activity_list_model.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_event.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_state.dart';
import 'package:orka_sports/presentation/view/body/activity_screen/activity_session/activity_session.dart';
import 'package:orka_sports/presentation/view/body/activity_screen/yogascreen.dart';
import 'package:orka_sports/presentation/view/body/activity_screen/zumbascreen.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _activityRepository = ActivityRepository();
  String? _loadingActivity;

  @override
  void initState() {
    super.initState();
    context.read<ActivityListBloc>().add(LoadActivityList());
  }

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'icon': Icons.directions_walk,
        'title': 'Walking',
        'desc': 'Track your daily walks and steps.',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.directions_run,
        'title': 'Running',
        'desc': 'Monitor your running sessions.',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.pedal_bike,
        'title': 'Cycling',
        'desc': 'Log your cycling workouts sessions.',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.self_improvement,
        'title': 'Yoga',
        'desc': 'Track your yoga and meditation sessions.',
        'color': AppColors.primary,

      },
      {
        'icon': Icons.sports_gymnastics,
        'title': 'Zumba',
        'desc': 'Join fun and energetic Zumba dance workouts.',
        'color': AppColors.primary,

      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<ActivityListBloc, ActivityListState>(
        builder: (context, state) {
          if (state is ActivityListLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ActivityListError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          } else if (state is ActivityListLoaded) {
            final getActivity = state.activities;

            if (getActivity.isEmpty) {
              return const Center(
                child: Text(
                  'No activities available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: ListView(
                children: activities.map((activity) {
                  final title = activity['title'] as String;
                  final icon = activity['icon'] as IconData;
                  final desc = activity['desc'] as String;
                  final color = activity['color'] as Color;

                  final isLoading = _loadingActivity == title;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Card(
                      color: color,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 28,
                          child: isLoading
                              ? const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          )
                              : Icon(
                            icon,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        onTap: isLoading
                            ? null
                            : () => _handleActivityTap(
                          title: title,
                          icon: icon,
                          getActivity: getActivity,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _handleActivityTap({
    required String title,
    required IconData icon,
    required List<ActivityListItem> getActivity,
  }) async {



    // 🔍 Debug: Print all available activities
    log("🔍 Available activities from API:");
    for (var activity in getActivity) {
      log("🔍 - '${activity.name}' (ID: ${activity.id})");
    }
    log("🔍 User tapped: '$title'");

    final matchingActivities = getActivity.where((act) =>
    act.name.trim().toLowerCase() == title.trim().toLowerCase()
    ).toList();

    log("🔍 Matching activities found: ${matchingActivities.length}");

    if (matchingActivities.isEmpty) {
      showCustomSnackbar(context, 'Activity coming soon for "$title"');
      return;
    }

    final activityId = matchingActivities.first.id;
    print('🔍 Sending activityId: $activityId for title: $title');

    if (title == "Yoga") {
      CustomSmoothNavigator.push(
        context,
        YogaScreen(activityId: activityId),
      );
      return;
    }
    if (title == "Zumba") {
      CustomSmoothNavigator.push(
        context,
        ZumbaScreen(activityId: activityId),
      );
      return;
    }

    try {
      setState(() {
        _loadingActivity = title;
      });

      final prefs = await SharedPreferences.getInstance();




      if (title == "Walking") {
        final walkData = await _activityRepository.getWalkRecommendation();
        await prefs.setString("recommended_distance_km", walkData.recommendedDistanceKm);
        await prefs.setString("goal", walkData.goal);
      } else if (title == "Running") {
        final runData = await _activityRepository.getRunRecommendation();
        await prefs.setString("recommended_distance_km", runData.recommendedRunPerDay);
        await prefs.setString("goal", runData.fitnessGoal);
      } else if (title == "Cycling") {
        final cyclingData = await _activityRepository.getCyclingRecommendation();
        await prefs.setString("recommended_distance_km", cyclingData.recommendedDistancePerDay);
        await prefs.setString("goal", cyclingData.fitnessGoal);
      }

      if (!mounted) return;
      final distanceKm = RegExp(r'[\d.]+').stringMatch(prefs.getString("recommended_distance_km").toString());
      CustomSmoothNavigator.push(
        context,
        ActivitySessionScreen(
          activityType: title,
          activityIcon: icon,
          activityId: activityId,
          yourGoal: prefs.getString("goal").toString() == "" || prefs.getString("goal") == null
              ? "YOUR GOAL"
              : prefs.getString("goal").toString(),
          distanceGoal: double.parse(distanceKm ?? '0'),
          activityRepo: _activityRepository,
        ),
      );
    } catch (e) {
      log("Error fetching recommendation: $e");
      showCustomSnackbar(context, 'Failed to fetch $title recommendation. Please calculated your BMI');
    } finally {
      setState(() {
        _loadingActivity = null;
      });
    }
  }
}
