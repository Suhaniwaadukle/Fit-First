import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/data/models/activity_model/activity_model.dart';
import 'package:orka_sports/presentation/blocs/activity/activity_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null && userId.isNotEmpty && mounted) {
      context.read<ActivityBloc>().add(FetchActivities(userId));
    } else {
      if (mounted) {
        // Let BLoC handle emitting a failure state if needed,
        // or show a message directly if BLoC doesn't cover this scenario from UI side.
        log('User ID not found or invalid in SharedPreferences for fetching activities.');
        // Optionally, emit a state directly if the BLoC event won't be dispatched
        // context.read<ActivityBloc>().emit(const ActivityOperationFailure("User ID not found. Please log in again."));
      }
    }
  }

  IconData _getActivityIcon(String? activityName) {
    switch (activityName?.toLowerCase()) {
      case 'running':
        return Icons.directions_run; // More common running icon
      case 'walk':
      case 'walking':
        return Icons.directions_walk;
      case 'cycling':
        return Icons.directions_bike;
      default:
        return Icons.fitness_center;
    }
  }

  int _parseDurationToSeconds(String timeTaken) {
    try {
      final parts = timeTaken.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return (hours * 3600) + (minutes * 60) + seconds;
      }
    } catch (e) {
      log("Error parsing duration '$timeTaken': $e");
    }
    return 0;
  }

  String _formatTotalSecondsForDisplay(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    // final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "$hours:${minutes}h"; // e.g., 1:20h
    } else if (duration.inMinutes > 0) {
      return "${duration.inMinutes}m"; // e.g., 25m
    }
    return "${duration.inSeconds}s"; // e.g., 45s
  }

  Map<String, List<ActivityData>> _groupActivitiesByMonth(List<ActivityData> activities) {
    final Map<String, List<ActivityData>> grouped = {};
    for (var activity in activities) {
      if (activity.createdAt != null) {
        try {
          DateTime dateTime = DateTime.parse(activity.createdAt!); // Assumes ISO8601 or compatible
          final key = DateFormat('MMMM yyyy').format(dateTime);
          if (grouped.containsKey(key)) {
            grouped[key]!.add(activity);
          } else {
            grouped[key] = [activity];
          }
        } catch (e) {
          log("Error parsing date for activity ${activity.id}: ${activity.createdAt} - $e");
          final fallbackKey = "Unknown Date";
          if (grouped.containsKey(fallbackKey)) {
            grouped[fallbackKey]!.add(activity);
          } else {
            grouped[fallbackKey] = [activity];
          }
        }
      }
    }
    // Sort activities within each month by date, most recent first
    grouped.forEach((key, monthActivities) {
      monthActivities.sort((a, b) {
        try {
          DateTime? dtA = a.createdAt != null ? DateTime.tryParse(a.createdAt!) : null;
          DateTime? dtB = b.createdAt != null ? DateTime.tryParse(b.createdAt!) : null;
          if (dtA != null && dtB != null) return dtB.compareTo(dtA);
          return dtA == null ? 1 : -1; // Nulls last
        } catch (_) {
          return 0;
        }
      });
    });
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityBloc, ActivityState>(
      builder: (context, state) {
        if (state is ActivityLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ActivityOperationFailure) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: ${state.error}', textAlign: TextAlign.center),
          ));
        } else if (state is ActivitiesLoaded) {
          if (state.activities.isEmpty) {
            return const Center(child: Text('No activities recorded yet.'));
          }

          final groupedActivities = _groupActivitiesByMonth(state.activities);
          final sortedMonthKeys = groupedActivities.keys.toList()
            ..sort((a, b) {
              try {
                if (a == "Unknown Date") return 1; // Push "Unknown Date" to the end
                if (b == "Unknown Date") return -1;
                final aDate = DateFormat('MMMM yyyy').parse(a);
                final bDate = DateFormat('MMMM yyyy').parse(b);
                return bDate.compareTo(aDate); // Most recent month first
              } catch (_) {
                return 0;
              }
            });

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sortedMonthKeys.length,
            itemBuilder: (context, index) {
              final monthYear = sortedMonthKeys[index];
              final activitiesForMonth = groupedActivities[monthYear]!;

              int totalDurationSecondsMonth = 0;
              double totalDistanceMonth = 0.0;
              double totalCaloriesMonth = 0.0;

              for (var activity in activitiesForMonth) {
                totalDurationSecondsMonth += _parseDurationToSeconds(activity.timeTaken);
                totalDistanceMonth += double.tryParse(activity.distance) ?? 0.0;
                totalCaloriesMonth += double.tryParse(activity.caloriesBurned) ?? 0.0;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MonthHeader(
                    monthYear: monthYear,
                    totalDuration: _formatTotalSecondsForDisplay(totalDurationSecondsMonth),
                    totalDistanceKm: totalDistanceMonth,
                    totalCalories: totalCaloriesMonth,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activitiesForMonth.length,
                    itemBuilder: (context, activityIndex) {
                      final activity = activitiesForMonth[activityIndex];
                      return _ActivityCard(
                        activity: activity,
                        icon: _getActivityIcon(activity.activityName),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        }
        return const Center(child: Text('Start an activity to see your history!'));
      },
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final String monthYear;
  final String totalDuration;
  final double totalDistanceKm;
  final double totalCalories;

  const _MonthHeader({
    required this.monthYear,
    required this.totalDuration,
    required this.totalDistanceKm,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthYear,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // IconButton(
              //   icon: Icon(Icons.add_circle_outline, color: Colors.grey.shade600, size: 28),
              //   onPressed: () {
              //     // TODO: Implement add manual activity functionality or remove
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(content: Text('Add manual activity (not implemented)')),
              //     );
              //   },
              // ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(totalDuration, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              const SizedBox(width: 12),
              Icon(Icons.space_dashboard_outlined, size: 16, color: Colors.grey.shade700), // Generic distance
              const SizedBox(width: 4),
              Text('${totalDistanceKm.toStringAsFixed(2)} km',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              const SizedBox(width: 12),
              Icon(Icons.local_fire_department_outlined, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text('${totalCalories.toStringAsFixed(0)} Cal',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityData activity;
  final IconData icon;

  const _ActivityCard({required this.activity, required this.icon});

  String _formatDisplayDate(String? createdAt) {
    if (createdAt == null) return "N/A";
    try {
      DateTime dateTime = DateTime.parse(createdAt); // Assumes ISO8601
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      log("Error formatting display date '$createdAt': $e");
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to activity detail screen or implement action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Tapped on activity: ${activity.activityName} on ${_formatDisplayDate(activity.createdAt)}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, size: 38, color: AppColors.primary), // Using AppColors.primary
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${double.tryParse(activity.distance)?.toStringAsFixed(2) ?? "0.00"} km',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatDisplayDate(activity.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity.activityName?.capitalizeFirst() ?? 'Activity',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(activity.timeTaken, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text('·', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ),
                        // As per UI, the "0 km" field seems odd. Using avgPace makes more sense here.
                        // If "0 km" is strictly needed, it needs clarification.
                        Text('${activity.avgPace} min/km', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text('·', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ),
                        Text('${double.tryParse(activity.caloriesBurned)?.toStringAsFixed(0) ?? "0"} Cal',
                            style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper extension for String capitalization
extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// If AppColors is not defined globally, you can define it here or import it.
// For example:
// class AppColors {
//   static const Color primary = Colors.green;
// }
