// To parse this JSON data, do
//
//     final getTodayWorkOutModel = getTodayWorkOutModelFromJson(jsonString);

import 'dart:convert';

GetTodayWorkOutModel getTodayWorkOutModelFromJson(String str) => GetTodayWorkOutModel.fromJson(json.decode(str));

String getTodayWorkOutModelToJson(GetTodayWorkOutModel data) => json.encode(data.toJson());

class GetTodayWorkOutModel {
  String? status;
  TodayWorkoutData? data;

  GetTodayWorkOutModel({
    this.status,
    this.data,
  });

  factory GetTodayWorkOutModel.fromJson(Map<String, dynamic> json) => GetTodayWorkOutModel(
        status: json["status"],
        data: json["data"] == null ? null : TodayWorkoutData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class TodayWorkoutData {
  String? day;
  String? workout;
  String? workoutTimeFrom;
  String? workoutTimeTo;
  String? buddyName;

  TodayWorkoutData({
    this.day,
    this.workout,
    this.workoutTimeFrom,
    this.workoutTimeTo,
    this.buddyName,
  });

  factory TodayWorkoutData.fromJson(Map<String, dynamic> json) => TodayWorkoutData(
        day: json["day"],
        workout: json["workout"],
        workoutTimeFrom: json["workout_time_from"],
        workoutTimeTo: json["workout_time_to"],
        buddyName: json["buddy_name"],
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "workout": workout,
        "workout_time_from": workoutTimeFrom,
        "workout_time_to": workoutTimeTo,
        "buddy_name": buddyName,
      };
}
