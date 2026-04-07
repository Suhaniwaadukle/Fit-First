import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/data/models/activity_model/activity_model.dart';
import 'package:orka_sports/presentation/blocs/activity/activity_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_event.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_state.dart';

enum HistoryType { weekly, monthly }

int _weekDayIndex(String day) {
  const order = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  return order.indexOf(day);
}

class HistoryScreen extends StatefulWidget {
  final String? activityType;
  const HistoryScreen({super.key, this.activityType});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  String _selectedActivity = "Walking";
  HistoryType selectedType = HistoryType.monthly;

  @override
  void initState() {
    super.initState();
    context.read<ActivityListBloc>().add(LoadActivityList());
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null && mounted) {
      context.read<ActivityBloc>().add(FetchActivities(userId));
    }
  }

  IconData _getActivityIcon(String? name) {
    switch (name?.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'walking':
      case 'walk':
        return Icons.directions_walk;
      case 'cycling':
        return Icons.pedal_bike;
      default:
        return Icons.fitness_center;
    }
  }

  int _parseDurationToSeconds(String timeTaken) {
    try {
      final parts = timeTaken.split(':');
      if (parts.length == 3) {
        return int.parse(parts[0]) * 3600 +
            int.parse(parts[1]) * 60 +
            int.parse(parts[2]);
      }
    } catch (e) {
      log("duration parse error");
    }
    return 0;
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "$hours:${minutes.toString().padLeft(2, '0')}h";
    }
    return "${duration.inMinutes}m";
  }

  Map<String, List<ActivityData>> _groupByWeek(List<ActivityData> activities) {
    final Map<String, List<ActivityData>> grouped = {};

    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    for (var a in activities) {
      if (a.createdAt == null) continue;

      DateTime date = DateTime.parse(a.createdAt!).toLocal();
      DateTime activityDate = DateTime(date.year, date.month, date.day);

      if (!activityDate.isBefore(startOfWeek) &&
          !activityDate.isAfter(endOfWeek)) {
        String dayName = DateFormat('EEEE').format(activityDate);
        grouped.putIfAbsent(dayName, () => []).add(a);
      }
    }

    return grouped;
  }

  Map<String, List<ActivityData>> _groupByMonth(List<ActivityData> activities) {
    final Map<String, List<ActivityData>> grouped = {};

    for (var a in activities) {
      if (a.createdAt != null) {
        DateTime date = DateTime.parse(a.createdAt!);
        String key = DateFormat('MMMM yyyy').format(date);
        grouped.putIfAbsent(key, () => []).add(a);
      }
    }

    return grouped;
  }

  Map<String, List<ActivityData>> _getGrouped(List<ActivityData> list) {
    switch (selectedType) {
      case HistoryType.weekly:
        return _groupByWeek(list);
      case HistoryType.monthly:
      default:
        return _groupByMonth(list);
    }
  }

  Widget _toggleButton(String text, HistoryType type) {
    bool selected = selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _toggleButton("Weekly", HistoryType.weekly),
          _toggleButton("Monthly", HistoryType.monthly),
        ],
      ),
    );
  }

  List<double> _buildGraphData(List<ActivityData> activities) {

    DateTime now = DateTime.now();

    // GOAL GRAPH
    if (_selectedActivity == "Goal") {

      double walking = 0;
      double running = 0;
      double cycling = 0;

      for (var a in activities) {

        final name = (a.activityName ?? "").toLowerCase();
        double dist = double.tryParse(a.distance) ?? 0;

        if (name == "walking" || name == "walk") {
          walking += dist;
        }

        if (name == "running" || name == "run") {
          running += dist;
        }

        if (name == "cycling" || name == "cycle" || name == "bike") {
          cycling += dist;
        }
      }

      double walkGoal = 5;
      double runGoal = 5;
      double cycleGoal = 15;

      double walkProgress = (walking / walkGoal).clamp(0.0, 1.0);
      double runProgress = (running / runGoal).clamp(0.0, 1.0);
      double cycleProgress = (cycling / cycleGoal).clamp(0.0, 1.0);

      // MINIMUM visible bar if activity exists
      if (walking > 0 && walkProgress < 0.05) {
        walkProgress = 0.05;
      }

      if (running > 0 && runProgress < 0.05) {
        runProgress = 0.05;
      }

      if (cycling > 0 && cycleProgress < 0.05) {
        cycleProgress = 0.05;
      }

      return [
        walkProgress,
        runProgress,
        cycleProgress,
      ];
    }

    // WEEKLY
    if (selectedType == HistoryType.weekly) {

      List<double> weeklyData = List.filled(7, 0);

      DateTime start = now.subtract(Duration(days: now.weekday - 1));

      for (var a in activities) {

        if (a.createdAt == null) continue;

        DateTime date = DateTime.parse(a.createdAt!).toLocal();
        int diff = date.difference(start).inDays;

        if (diff >= 0 && diff < 7) {
          weeklyData[diff] += 1;
        }
      }

      return weeklyData;
    }

    // MONTHLY
    List<double> monthlyData = List.filled(7, 0);

    for (var a in activities) {

      if (a.createdAt == null) continue;

      DateTime date = DateTime.parse(a.createdAt!).toLocal();

      int diff = (now.year - date.year) * 12 + now.month - date.month;

      if (diff >= 0 && diff < 7) {
        monthlyData[6 - diff] += 1;
      }
    }

    return monthlyData;
  }

  Widget _buildAnimatedGraph(List<ActivityData> activities) {

    final data = _buildGraphData(activities);

    double maxY = _selectedActivity == "Goal"
        ? 1
        : (data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) + 1 : 1);

    final weekLabels = ["M", "T", "W", "T", "F", "S", "S"];

    List<String> _getMonthLabels() {

      final months = [
        "Jan",
        "Feb",
        "March",
        "April",
        "May",
        "June",
        "July",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];

      DateTime now = DateTime.now();
      List<String> result = [];

      for (int i = 6; i >= 0; i--) {

        int index = (now.month - i - 1) % 12;

        if (index < 0) index += 12;

        result.add(months[index]);
      }

      return result;
    }

    final monthLabels = _getMonthLabels();

    final labels = _selectedActivity == "Goal"
        ? ["Walk", "Run", "Cycle"]
        : selectedType == HistoryType.weekly
        ? weekLabels
        : monthLabels;

    final activitiesIcons = [
      {'icon': Icons.directions_walk, 'title': 'Walking'},
      {'icon': Icons.directions_run, 'title': 'Running'},
      {'icon': Icons.pedal_bike, 'title': 'Cycling'},
      {'icon': Icons.emoji_events, 'title': 'Goal'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(.50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: activitiesIcons.map((activity) {

              final title = activity['title'] as String;
              final icon = activity['icon'] as IconData;
              final isSelected = _selectedActivity == title;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedActivity = title;
                  });
                },
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.shade500,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.trending_up,
                  color: AppColors.primary,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                "Activity Trend",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                borderData: FlBorderData(show: false),

                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(.15),
                      strokeWidth: 1,
                    );
                  },
                ),

                titlesData: FlTitlesData(

                  leftTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {

                        int index = value.toInt();

                        if (index >= labels.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups: List.generate(data.length, (i) {

                  final value = data[i];

                  return BarChartGroupData(
                    x: i,
                    barRods: [

                      BarChartRodData(
                        toY: value,
                        width: 16,

                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),

                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.primary.withOpacity(.55),
                            AppColors.primary,
                          ],
                        ),

                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.grey.withOpacity(.08),
                        ),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<ActivityListBloc, ActivityListState>(
        builder: (context, listState) {

          if (listState is ActivityListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (listState is ActivityListLoaded) {

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),

              child: Column(
                children: [

                  BlocBuilder<ActivityBloc, ActivityState>(
                    builder: (context, state) {

                      if (state is ActivitiesLoaded) {

                        final filteredActivities =
                        state.activities.where((a) {

                          final name =
                          (a.activityName ?? "").toLowerCase().trim();
                          final selected =
                          _selectedActivity.toLowerCase();

                          if (selected == "walking") {
                            return name == "walking" || name == "walk";
                          }

                          if (selected == "running") {
                            return name == "running" || name == "run";
                          }

                          if (selected == "cycling") {
                            return name == "cycling" ||
                                name == "cycle" ||
                                name == "bike";
                          }

                          if (selected == "goal") {
                            return name == "walking" ||
                                name == "walk" ||
                                name == "running" ||
                                name == "run" ||
                                name == "cycling" ||
                                name == "cycle" ||
                                name == "bike";
                          }

                          return false;

                        }).toList();

                        final grouped = _getGrouped(filteredActivities);

                        final keys = grouped.keys.toList()
                          ..sort((a, b) =>
                              _weekDayIndex(a).compareTo(_weekDayIndex(b)));

                        return Expanded(
                          child: Column(
                            children: [

                              _buildToggle(),

                              _buildAnimatedGraph(filteredActivities),

                              Expanded(
                                child: ListView.builder(
                                  itemCount: keys.length,

                                  itemBuilder: (context, index) {

                                    final key = keys[index];
                                    final activities = grouped[key]!;

                                    int totalDuration = 0;
                                    double totalDistance = 0;
                                    double totalCalories = 0;

                                    for (var a in activities) {

                                      totalDuration +=
                                          _parseDurationToSeconds(a.timeTaken);

                                      totalDistance +=
                                          double.tryParse(a.distance) ?? 0;

                                      totalCalories +=
                                          double.tryParse(a.caloriesBurned) ??
                                              0;
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        _Header(
                                          title: key,
                                          duration:
                                          _formatDuration(totalDuration),
                                          distance: totalDistance,
                                          calories: totalCalories,
                                        ),

                                        ...activities.map(
                                              (a) => _ActivityCard(
                                            activity: a,
                                            icon: _getActivityIcon(
                                                a.activityName),
                                          ),
                                        ),

                                        const SizedBox(height: 16)
                                      ],
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {

  final String title;
  final String duration;
  final double distance;
  final double calories;

  const _Header({
    required this.title,
    required this.duration,
    required this.distance,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(title,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

          const SizedBox(height: 5),

          Row(
            children: [

              const Icon(Icons.timer, size: 16, color: Colors.green),

              const SizedBox(width: 4),

              Text(duration),

              const SizedBox(width: 14),

              const Icon(Icons.route, size: 16, color: Colors.brown),

              const SizedBox(width: 4),

              Text("${distance.toStringAsFixed(2)} km"),

              const SizedBox(width: 14),

              const Icon(Icons.local_fire_department,
                  size: 16, color: Colors.orange),

              const SizedBox(width: 4),

              Text("${calories.toStringAsFixed(0)} Cal"),
            ],
          )
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {

  final ActivityData activity;
  final IconData icon;

  const _ActivityCard({
    required this.activity,
    required this.icon,
  });

  String _formatDate(String? createdAt) {

    if (createdAt == null) return "";

    DateTime date = DateTime.parse(createdAt);

    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(.35)),
      ),

      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(.15),
            ),

            child: Icon(icon, size: 26, color: AppColors.primary),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    Text(
                      "${double.tryParse(activity.distance)?.toStringAsFixed(2) ?? "0"} km",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    Text(_formatDate(activity.createdAt),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700))
                  ],
                ),

                const SizedBox(height: 4),

                Text(activity.activityName ?? "Activity",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),

                const SizedBox(height: 4),

                Text(
                    "${activity.timeTaken} • ${activity.avgPace} min/km • ${activity.caloriesBurned} Cal",
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.grey)
        ],
      ),
    );
  }
}