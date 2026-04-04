class FullScheduleResponse {
  final String status;
  final FullScheduleData data;

  FullScheduleResponse({
    required this.status,
    required this.data,
  });

  factory FullScheduleResponse.fromJson(Map<String, dynamic> json) {
    return FullScheduleResponse(
      status: json['status'] ?? '',
      data: FullScheduleData.fromJson(json['data'] ?? {}),
    );
  }
}

class FullScheduleData {
  final DailySchedule? dailySchedule;
  final MealSchedule? mealSchedule;
  final List<Supplement> supplements;

  FullScheduleData({
    this.dailySchedule,
    this.mealSchedule,
    required this.supplements,
  });

  factory FullScheduleData.fromJson(Map<String, dynamic> json) {

    DailySchedule? schedule;

    if (json['daily_schedule'] != null) {

      // If backend sends LIST
      if (json['daily_schedule'] is List) {
        final list = json['daily_schedule'] as List;
        if (list.isNotEmpty) {
          schedule = DailySchedule.fromJson(list.first);
        }
      }

      // If backend sends OBJECT
      else if (json['daily_schedule'] is Map) {
        schedule = DailySchedule.fromJson(json['daily_schedule']);
      }
    }

    return FullScheduleData(
      dailySchedule: schedule,
      mealSchedule: json['meal_schedule'] != null
          ? MealSchedule.fromJson(json['meal_schedule'])
          : null,
      supplements: (json['supplements'] as List<dynamic>?)
          ?.map((item) => Supplement.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class DailySchedule {
  final String id;
  final String userId;
  final String day;
  final String workout;
  final String workoutTimeFrom;
  final String workoutTimeTo;
  final String workoutStatus;
  final String createdAt;

  DailySchedule({
    required this.id,
    required this.userId,
    required this.day,
    required this.workout,
    required this.workoutTimeFrom,
    required this.workoutTimeTo,
    required this.workoutStatus,
    required this.createdAt,
  });

  factory DailySchedule.fromJson(Map<String, dynamic> json) {
    return DailySchedule(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      workout: json['workout']?.toString() ?? '',
      workoutTimeFrom: json['workout_time_from']?.toString() ?? '',
      workoutTimeTo: json['workout_time_to']?.toString() ?? '',
      workoutStatus: json['workout_status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class MealSchedule {
  final String id;
  final String userId;
  final String day;
  final String breakfast;
  final String midMorningSnack;
  final String lunch;
  final String preWorkout;
  final String postWorkout;
  final String dinner;
  final String bedtimeProtein;
  final String status;
  final String createdAt;

  MealSchedule({
    required this.id,
    required this.userId,
    required this.day,
    required this.breakfast,
    required this.midMorningSnack,
    required this.lunch,
    required this.preWorkout,
    required this.postWorkout,
    required this.dinner,
    required this.bedtimeProtein,
    required this.status,
    required this.createdAt,
  });

  factory MealSchedule.fromJson(Map<String, dynamic> json) {
    return MealSchedule(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      breakfast: json['breakfast']?.toString() ?? '',
      midMorningSnack: json['mid_morning_snack']?.toString() ?? '',
      lunch: json['lunch']?.toString() ?? '',
      preWorkout: json['pre_workout']?.toString() ?? '',
      postWorkout: json['post_workout']?.toString() ?? '',
      dinner: json['dinner']?.toString() ?? '',
      bedtimeProtein: json['bedtime_protein']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class Supplement {
  final String id;
  final String userId;
  final String day;
  final String supplementName;
  final String timeSlot;
  final String time;
  final String createdAt;

  Supplement({
    required this.id,
    required this.userId,
    required this.day,
    required this.supplementName,
    required this.timeSlot,
    required this.time,
    required this.createdAt,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) {
    return Supplement(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      supplementName: json['supplement_name']?.toString() ?? '',
      timeSlot: json['time_slot']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}