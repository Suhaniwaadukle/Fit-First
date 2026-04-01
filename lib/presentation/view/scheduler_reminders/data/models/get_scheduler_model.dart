import 'dart:convert';

GetFullScheduleModel getFullScheduleModelFromJson(String str) => GetFullScheduleModel.fromJson(json.decode(str));

String getFullScheduleModelToJson(GetFullScheduleModel data) => json.encode(data.toJson());

class GetFullScheduleModel {
  String? status;
  Data? data;

  GetFullScheduleModel({
    this.status,
    this.data,
  });

  factory GetFullScheduleModel.fromJson(Map<String, dynamic> json) => GetFullScheduleModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  DailySchedule? dailySchedule;
  MealSchedule? mealSchedule;
  Reminders? reminders;
  List<Supplement>? supplements;

  Data({
    this.dailySchedule,
    this.mealSchedule,
    this.reminders,
    this.supplements,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        dailySchedule: json["daily_schedule"] == null ? null : DailySchedule.fromJson(json["daily_schedule"]),
        mealSchedule: json["meal_schedule"] == null ? null : MealSchedule.fromJson(json["meal_schedule"]),
        reminders: json["reminders"] == null ? null : Reminders.fromJson(json["reminders"]),
        supplements: json["supplements"] == null
            ? []
            : List<Supplement>.from(json["supplements"]!.map((x) => Supplement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "daily_schedule": dailySchedule?.toJson(),
        "meal_schedule": mealSchedule?.toJson(),
        "reminders": reminders?.toJson(),
        "supplements": supplements == null ? [] : List<dynamic>.from(supplements!.map((x) => x.toJson())),
      };
}

class DailySchedule {
  String? id;
  String? userId;
  String? day;
  String? workout;
  String? workoutTimeFrom;
  String? workoutTimeTo;
  DateTime? createdAt;

  DailySchedule({
    this.id,
    this.userId,
    this.day,
    this.workout,
    this.workoutTimeFrom,
    this.workoutTimeTo,
    this.createdAt,
  });

  factory DailySchedule.fromJson(Map<String, dynamic> json) => DailySchedule(
        id: json["id"],
        userId: json["user_id"],
        day: json["day"],
        workout: json["workout"],
        workoutTimeFrom: json["workout_time_from"],
        workoutTimeTo: json["workout_time_to"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "day": day,
        "workout": workout,
        "workout_time_from": workoutTimeFrom,
        "workout_time_to": workoutTimeTo,
        "created_at": createdAt?.toIso8601String(),
      };
}

class MealSchedule {
  String? id;
  String? userId;
  String? day;
  String? breakfast;
  String? midMorningSnack;
  String? lunch;
  String? preWorkout;
  String? postWorkout;
  String? dinner;
  String? bedtimeProtein;
  String? status;
  DateTime? createdAt;

  MealSchedule({
    this.id,
    this.userId,
    this.day,
    this.breakfast,
    this.midMorningSnack,
    this.lunch,
    this.preWorkout,
    this.postWorkout,
    this.dinner,
    this.bedtimeProtein,
    this.status,
    this.createdAt,
  });

  factory MealSchedule.fromJson(Map<String, dynamic> json) => MealSchedule(
        id: json["id"],
        userId: json["user_id"],
        day: json["day"],
        breakfast: json["breakfast"],
        midMorningSnack: json["mid_morning_snack"],
        lunch: json["lunch"],
        preWorkout: json["pre_workout"],
        postWorkout: json["post_workout"],
        dinner: json["dinner"],
        bedtimeProtein: json["bedtime_protein"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "day": day,
        "breakfast": breakfast,
        "mid_morning_snack": midMorningSnack,
        "lunch": lunch,
        "pre_workout": preWorkout,
        "post_workout": postWorkout,
        "dinner": dinner,
        "bedtime_protein": bedtimeProtein,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
      };
}

class Reminders {
  String? id;
  String? userId;
  String? day;
  String? waterReminder;
  String? meditationTime;
  String? exerciseTime;
  DateTime? createdAt;

  Reminders({
    this.id,
    this.userId,
    this.day,
    this.waterReminder,
    this.meditationTime,
    this.exerciseTime,
    this.createdAt,
  });

  factory Reminders.fromJson(Map<String, dynamic> json) => Reminders(
        id: json["id"],
        userId: json["user_id"],
        day: json["day"],
        waterReminder: json["water_reminder"],
        meditationTime: json["meditation_time"],
        exerciseTime: json["exercise_time"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "day": day,
        "water_reminder": waterReminder,
        "meditation_time": meditationTime,
        "exercise_time": exerciseTime,
        "created_at": createdAt?.toIso8601String(),
      };
}

class Supplement {
  String? id;
  String? userId;
  String? day;
  String? supplementName;
  String? timeSlot;
  String? time;
  DateTime? createdAt;

  Supplement({
    this.id,
    this.userId,
    this.day,
    this.supplementName,
    this.timeSlot,
    this.time,
    this.createdAt,
  });

  factory Supplement.fromJson(Map<String, dynamic> json) => Supplement(
        id: json["id"],
        userId: json["user_id"],
        day: json["day"],
        supplementName: json["supplement_name"],
        timeSlot: json["time_slot"],
        time: json["time"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "day": day,
        "supplement_name": supplementName,
        "time_slot": timeSlot,
        "time": time,
        "created_at": createdAt?.toIso8601String(),
      };
}
