import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
        'color': AppColors.primary,
      },
      {
        'icon': Icons.directions_run,
        'title': 'Running',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.hiking,
        'title': 'Hiking',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.pedal_bike,
        'title': 'Cycling',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.self_improvement,
        'title': 'Yoga',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.sports_gymnastics,
        'title': 'Zumba',
        'color': AppColors.primary,
      },
      // {
      //   'icon': FontAwesomeIcons.handRock, // MMA
      //   'title': 'MMA',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.fistRaised, // Boxing
      //   'title': 'Boxing',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.userNinja, // Muay Thai
      //   'title': 'Muay Thai',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.personRunning,
      //   'title': 'Kickboxing',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.shieldAlt,
      //   'title': 'BJJ',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.userShield,
      //   'title': 'Judo',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.personBooth,
      //   'title': 'Wrestling',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.personRunning,
      //   'title': 'Karate',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.personDress,
      //   'title': 'Taekwondo',
      //   'color': AppColors.primary,
      // },
      // {
      //   'icon': FontAwesomeIcons.userNinja,
      //   'title': 'Kung Fu',
      //   'color': AppColors.primary,
      // },
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Builder(
                      builder: (context) {
                        final sw = MediaQuery.of(context).size.width;
                        final titleSize = (sw * 0.052).clamp(14.0, 22.0);
                        final bodySize = (sw * 0.036).clamp(11.0, 16.0);
                        final lottieHeight = (sw * 0.22).clamp(60.0, 100.0);

                        return Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Fitness Dashboard',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: sw * 0.025),
                                  Text(
                                    '• Monitor your daily workouts\n'
                                        '• Track your steps and distance\n'
                                        '• Monitor calories burned\n'
                                        '• Stay on top of your fitness goals',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: bodySize,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Lottie.asset(
                                'assets/Lottie/card.json',
                                height: lottieHeight,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Explore activities",
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth < 360
                          ? 2
                          : constraints.maxWidth < 600
                          ? 3
                          : 4;

                      final spacing = constraints.maxWidth < 360 ? 8.0 : 12.0;
                      final totalSpacing = spacing * (crossAxisCount - 1);
                      final cardWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
                      final cardHeight = cardWidth * 0.8;

                      final avatarRadius = (cardWidth * 0.22).clamp(18.0, 32.0);
                      final iconSize = (cardWidth * 0.22).clamp(14.0, 28.0);
                      final fontSize = (cardWidth * 0.13).clamp(10.0, 16.0);
                      final innerPadding = (cardWidth * 0.06).clamp(4.0, 8.0);
                      final gapHeight = (cardWidth * 0.08).clamp(4.0, 12.0);
                      final strokeWidth = (cardWidth * 0.04).clamp(2.0, 3.0);

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activities.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          final title = activity['title'] as String;
                          final color = activity['color'] as Color;
                          final isLoading = _loadingActivity == title;

                          return GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => _handleActivityTap(
                              title: title,
                              icon: activity['icon'],
                              getActivity: getActivity,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(innerPadding),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color.withOpacity(0.9), color],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: avatarRadius,
                                    backgroundColor: Colors.white,
                                    child: isLoading
                                        ? CircularProgressIndicator(
                                      strokeWidth: strokeWidth,
                                      valueColor: const AlwaysStoppedAnimation(
                                          AppColors.primary),
                                    )
                                        : (activity['icon'] is IconData
                                        ? Icon(
                                      activity['icon'] as IconData,
                                      size: iconSize,
                                      color: AppColors.primary,
                                    )
                                        : FaIcon(
                                      activity['icon'] as FaIconData,
                                      size: iconSize,
                                      color: AppColors.primary,
                                    )),
                                  ),
                                  SizedBox(height: gapHeight),
                                  Flexible(
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSize,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
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
    required dynamic icon,
    required List<ActivityListItem> getActivity,
  }) async
  {
    print("🔍 User tapped: '$title'");

    print("All activities: ${getActivity.map((e) => e.name).toList()}");
    print("Clicked: $title");

    final matchingActivities = getActivity
        .where((act) => act.name.trim().toLowerCase() ==
        title.trim().toLowerCase())
        .toList();

    if (matchingActivities.isEmpty) {
      showCustomSnackbar(context, 'Activity coming soon for "$title"');
      return;
    }

    final activityId = matchingActivities.first.id;

    if (title == "Yoga") {
      CustomSmoothNavigator.push(context, YogaScreen(activityId: activityId));
      return;
    }

    if (title == "Zumba") {
      CustomSmoothNavigator.push(context, ZumbaScreen(activityId: activityId));
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
      } else if (title == "Hiking") {
        final hikingData = await _activityRepository.getHikingRecommendation();
        await prefs.setString("recommended_distance_km", hikingData.distance);
        await prefs.setString("goal", hikingData.fitnessGoal);
      }

      if (!mounted) return;
      final distanceKm = RegExp(r'[\d.]+')
          .stringMatch(prefs.getString("recommended_distance_km").toString());

      CustomSmoothNavigator.push(
        context,
        ActivitySessionScreen(
          activityType: title,
          activityIcon: icon,
          activityId: activityId,
          yourGoal: prefs.getString("goal").toString().isEmpty
              ? "Start your, Fitness Journey"
              : prefs.getString("goal").toString(),
          // distanceGoal: double.parse(distanceKm ?? '0'),
          distanceGoal: 0.001,
          activityRepo: _activityRepository,
        ),
      );
    } catch (e) {
      print("Error fetching recommendation: $e");
      showCustomSnackbar(
          context, 'Failed to fetch $title recommendation. Please calculate your BMI');
    } finally {
      setState(() {
        _loadingActivity = null;
      });
    }
  }
}