import 'dart:convert';

GetGymBuddyDetailsModel getGymBuddyDetailsModelFromJson(String str) =>
    GetGymBuddyDetailsModel.fromJson(json.decode(str));

String getGymBuddyDetailsModelToJson(GetGymBuddyDetailsModel data) => json.encode(data.toJson());

class GetGymBuddyDetailsModel {
  String? status;
  GymBuddyDetailsData? data;
  String? message;

  GetGymBuddyDetailsModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetGymBuddyDetailsModel.fromJson(Map<String, dynamic> json) => GetGymBuddyDetailsModel(
        status: json["status"],
        data: json["data"] == null ? null : GymBuddyDetailsData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
        "message": message,
      };
}

class GymBuddyDetailsData {
  Profile? profile;
  List<WeeklySchedule>? weeklySchedule;

  GymBuddyDetailsData({
    this.profile,
    this.weeklySchedule,
  });

  factory GymBuddyDetailsData.fromJson(Map<String, dynamic> json) => GymBuddyDetailsData(
        profile: json["profile"] == null ? null : Profile.fromJson(json["profile"]),
        weeklySchedule: json["weekly_schedule"] == null
            ? []
            : List<WeeklySchedule>.from(json["weekly_schedule"]!.map((x) => WeeklySchedule.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "profile": profile?.toJson(),
        "weekly_schedule": weeklySchedule == null ? [] : List<dynamic>.from(weeklySchedule!.map((x) => x.toJson())),
      };
}

class Profile {
  String? fitnessGoal;
  String? experienceLevel;
  String? communicationStyle;
  String? genderPreferenceForBuddy;
  String? name;
  String? image;
  String? age;
  String? fitnessLevel;
   String? userId;

  Profile({
    this.fitnessGoal,
    this.experienceLevel,
    this.communicationStyle,
    this.genderPreferenceForBuddy,
    this.name,
    this.image,
    this.age,
    this.fitnessLevel,
    this.userId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        fitnessGoal: json["fitness_goal"],
        experienceLevel: json["experience_level"],
        communicationStyle: json["communication_style"],
        genderPreferenceForBuddy: json["gender_preference_for_buddy"],
        name: json["name"],
        image: json["image"],
        age: json["age"],
        fitnessLevel: json["fitness_level"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "fitness_goal": fitnessGoal,
        "experience_level": experienceLevel,
        "communication_style": communicationStyle,
        "gender_preference_for_buddy": genderPreferenceForBuddy,
        "name": name,
        "image": image,
        "age": age,
        "fitness_level": fitnessLevel,
         "user_id": userId,
      };
}

class WeeklySchedule {
  String? day;
  String? workout;
  String? workoutTimeFrom;
  String? workoutTimeTo;

  WeeklySchedule({
    this.day,
    this.workout,
    this.workoutTimeFrom,
    this.workoutTimeTo,
  });

  factory WeeklySchedule.fromJson(Map<String, dynamic> json) => WeeklySchedule(
        day: json["day"],
        workout: json["workout"],
        workoutTimeFrom: json["workout_time_from"],
        workoutTimeTo: json["workout_time_to"],
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "workout": workout,
        "workout_time_from": workoutTimeFrom,
        "workout_time_to": workoutTimeTo,
      };
}
