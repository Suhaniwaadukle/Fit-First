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
  const
  HistoryScreen({super.key, this.activityType});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryType selectedType = HistoryType.monthly;
  String _selectedActivity = 'Running';


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
      case 'hiking':
        return Icons.hiking;
      default:
        return Icons.fitness_center;
    }
  }

  int _parseDurationToSeconds(String timeTaken) {
    if (timeTaken == null || timeTaken.isEmpty) return 0;
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

  Widget _buildAnimatedGraph(List<ActivityData> activities) {
    List<double> _getGraphDataByActivity() {
      if (selectedType == HistoryType.weekly) {
        final weekLabels = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
        final Map<String, double> dayData = {for (var d in weekLabels) d: 0.0};

        for (var a in activities) {
          if (a.createdAt == null) continue;
          final date = DateTime.parse(a.createdAt!).toLocal();
          final dayName = DateFormat('EEEE').format(date);
          if (!dayData.containsKey(dayName)) continue;

          switch (_selectedActivity) {
            case 'Distance':
              dayData[dayName] = (dayData[dayName] ?? 0) + (double.tryParse(a.distance ?? "0") ?? 0);
              break;
            case 'Duration':
              dayData[dayName] = (dayData[dayName] ?? 0) + (_parseDurationToSeconds(a.timeTaken ?? "00:00:00") / 60.0);
              break;
            case 'Calories':
              dayData[dayName] = (dayData[dayName] ?? 0) + (double.tryParse(a.caloriesBurned ?? "0") ?? 0);
              break;
            case 'Pace':
              dayData[dayName] = (dayData[dayName] ?? 0) + (double.tryParse(a.avgPace ?? "0") ?? 0);
              break;
            default:
              dayData[dayName] = (dayData[dayName] ?? 0) + (double.tryParse(a.distance ?? "0") ?? 0);
          }
        }
        return weekLabels.map((d) => dayData[d] ?? 0.0).toList();

      } else {
        DateTime now = DateTime.now();
        final Map<String, double> monthData = {};
        final monthLabels = <String>[];

        for (int i = 6; i >= 0; i--) {
          final dt = DateTime(now.year, now.month - i, 1);
          final key = DateFormat('MMM yyyy').format(dt);
          monthLabels.add(key);
          monthData[key] = 0.0;
        }

        for (var a in activities) {
          if (a.createdAt == null) continue;
          final date = DateTime.parse(a.createdAt!).toLocal();
          final key = DateFormat('MMM yyyy').format(date);
          if (!monthData.containsKey(key)) continue;

          switch (_selectedActivity) {
            case 'Distance':
              monthData[key] = (monthData[key] ?? 0) + (double.tryParse(a.distance ?? "0") ?? 0);
              break;
            case 'Duration':
              monthData[key] = (monthData[key] ?? 0) + (_parseDurationToSeconds(a.timeTaken ?? "0") / 60.0);
              break;
            case 'Calories':
              monthData[key] = (monthData[key] ?? 0) + (double.tryParse(a.caloriesBurned ?? "0") ?? 0);
              break;
            case 'Pace':
              monthData[key] = (monthData[key] ?? 0) + (double.tryParse(a.avgPace ?? "0") ?? 0);
              break;
            default:
              monthData[key] = (monthData[key] ?? 0) + (double.tryParse(a.distance ?? "0") ?? 0);
          }
        }
        return monthLabels.map((k) => monthData[k] ?? 0.0).toList();
      }
    }

    final data = _getGraphDataByActivity();
    final maxY = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) + 1 : 1.0;

    List<String> _getLabels() {
      if (selectedType == HistoryType.weekly) {
        return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      } else {
        final months = [
          "Jan", "Feb", "Mar", "Apr", "May", "Jun",
          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
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
    }

    final labels = _getLabels();

    final statCards = [
      {'icon': _getActivityIcon(widget.activityType ?? 'running'), 'label': 'Running', 'color': Colors.green.shade700, 'title': (widget.activityType ?? 'Activities'),},
      {'icon': Icons.emoji_events, 'label': 'Goal', 'color': Colors.teal.shade700,'title': 'Goal'},
      {'icon': Icons.location_on, 'label': 'Distance', 'color': Colors.brown,'title': 'Distance(km)'},
      {'icon': Icons.timer, 'label': 'Duration', 'color': Colors.blue.shade700,'title': 'Duration(hr:min)'},
      {'icon': Icons.local_fire_department, 'label': 'Calories', 'color': Colors.orange.shade900,'title': 'Calories(cal)'},
      {'icon': Icons.speed, 'label': 'Pace', 'color': Colors.green,'title': 'Pace(min/km)'},
    ];

    final selectedColor = statCards.firstWhere(
          (card) => card['label'] == _selectedActivity,
      orElse: () => statCards[0],
    )['color'] as Color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sw = MediaQuery.of(context).size.width;
        final isSmall = sw < 360;

        final containerMargin = isSmall
            ? const EdgeInsets.fromLTRB(8, 0, 8, 8)
            : const EdgeInsets.fromLTRB(12, 0, 12, 10);
        final containerPadding = isSmall ? 8.0 : 10.0;
        final iconSize = isSmall ? 22.0 : 28.0;
        final iconHPad = isSmall ? 4.0 : 6.0;
        final chartHeight = isSmall ? 120.0 : 150.0;
        final barWidth = isSmall ? 10.0 : 16.0;
        final bottomLabelSize = isSmall ? 9.0 : 11.0;
        final titleFontSize = isSmall ? 13.0 : 16.0;
        final trendFontSize = isSmall ? 12.0 : 14.0;
        final trendIconSize = isSmall ? 15.0 : 18.0;
        final spacing1 = isSmall ? 10.0 : 16.0;
        final spacing2 = isSmall ? 10.0 : 14.0;
        final spacing3 = isSmall ? 6.0 : 10.0;

        return Container(
          margin: containerMargin,
          padding: EdgeInsets.all(containerPadding),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: statCards.map((card) {
                  final label = card['label'] as String;
                  final icon = card['icon'] as IconData;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedActivity = label;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: iconHPad),
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: _selectedActivity == label
                            ? card['color'] as Color
                            : Colors.grey.shade500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: spacing1),

              Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.primary, size: trendIconSize),
                  const SizedBox(width: 6),
                  Text(
                    "Activity Trend",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: trendFontSize,
                    ),
                  ),
                ],
              ),

              SizedBox(height: spacing2),

              SizedBox(
                height: chartHeight,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(.15),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= labels.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: bottomLabelSize,
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
                            width: barWidth,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                selectedColor.withOpacity(.55),
                                selectedColor,
                              ],
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY,
                              color: Colors.grey.withOpacity(.08),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              SizedBox(height: spacing3),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    statCards.firstWhere(
                          (card) => card['label'] == _selectedActivity,
                      orElse: () => statCards[0],
                    )['title'] as String,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
                        final selected = widget.activityType?.toLowerCase() ?? "";
                        final filteredActivities = state.activities.where((a) {
                          final name = (a.activityName ?? "").toLowerCase();
                          if (selected == "walking") return name == "walking" || name == "walk";
                          if (selected == "running") return name == "running" || name == "run";
                          if (selected == "cycling") return name == "cycling" || name == "cycle" || name == "bike";
                          if (selected == "hiking") return name == "hiking" || name == "unknown" || name == "Hiking".toLowerCase();
                          return name.contains(selected);
                        }).toList();

                        print("history: $_selectedActivity");
                        print("All activities: ${state.activities.map((a) => a.activityName).toList()}");
                        print("Selected Activity: $selected");
                        print("Filtered Count: ${filteredActivities.length}");

                        final grouped = _getGrouped(filteredActivities);

                        final keys = grouped.keys.toList()
                          ..sort((a, b) => _weekDayIndex(a).compareTo(_weekDayIndex(b)));

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
                                      totalDuration += _parseDurationToSeconds(a.timeTaken ?? "00:00:00");
                                      totalDistance += double.tryParse(a.distance ?? "0") ?? 0;
                                      totalCalories += double.tryParse(a.caloriesBurned ?? "0") ?? 0;
                                    }

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _Header(
                                          title: key,
                                          duration: _formatDuration(totalDuration),
                                          distance: totalDistance,
                                          calories: totalCalories,
                                        ),
                                        ...activities.map(
                                              (a) => _ActivityCard(
                                            activity: a,
                                            icon: _getActivityIcon(a.activityName ?? ""),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    );
                                  },
                                ),
                              ),
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
    if (createdAt == null || createdAt.isEmpty) return "";
    try {
      DateTime date = DateTime.parse(createdAt);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return "";
    }
  }

  // ✅ Duration format validate karo
  String _formatDuration(String raw) {
    if (raw.isEmpty || raw == "null" || raw == "0") return "00:00:00";

    // Agar already HH:MM:SS format mein hai
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(raw)) return raw;

    // Agar sirf seconds mein aa raha hai (e.g. "3600")
    final seconds = int.tryParse(raw);
    if (seconds != null) {
      final h = (seconds ~/ 3600).toString().padLeft(2, '0');
      final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
      final s = (seconds % 60).toString().padLeft(2, '0');
      return "$h:$m:$s";
    }

    return raw; // as-is return karo
  }

  @override
  Widget build(BuildContext context) {
    final distance =
        double.tryParse(activity.distance)?.toStringAsFixed(2) ?? "0.00";

    final duration = _formatDuration(activity.timeTaken); // ✅ validated

    final pace = activity.avgPace.isNotEmpty && activity.avgPace != "null"
        ? "${activity.avgPace} min/km"
        : "--";

    final calories = activity.caloriesBurned.isNotEmpty &&
        activity.caloriesBurned != "null"
        ? "${activity.caloriesBurned} Cal"
        : "0 Cal";

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
                      "$distance km",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      _formatDate(activity.createdAt),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  activity.activityName?.toLowerCase() == 'unknown'
                      ? 'Hiking'
                      : activity.activityName ?? "Activity",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                Text(
                  "$duration • $pace • $calories",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}