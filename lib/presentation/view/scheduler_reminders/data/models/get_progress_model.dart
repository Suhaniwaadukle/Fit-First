// To parse this JSON data, do
//
//     final getWeeklyProgressModel = getWeeklyProgressModelFromJson(jsonString);

import 'dart:convert';

GetWeeklyProgressModel getWeeklyProgressModelFromJson(String str) => GetWeeklyProgressModel.fromJson(json.decode(str));

String getWeeklyProgressModelToJson(GetWeeklyProgressModel data) => json.encode(data.toJson());

class GetWeeklyProgressModel {
  String? status;
  Progress? progress;

  GetWeeklyProgressModel({
    this.status,
    this.progress,
  });

  factory GetWeeklyProgressModel.fromJson(Map<String, dynamic> json) => GetWeeklyProgressModel(
        status: json["status"],
        progress: json["progress"] == null ? null : Progress.fromJson(json["progress"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "progress": progress?.toJson(),
      };
}

class Progress {
  String? completedDays;
  String? totalDays;
  String? percentage;

  Progress({
    this.completedDays,
    this.totalDays,
    this.percentage,
  });

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        completedDays: json["completed_days"].toString(),
        totalDays: json["total_days"].toString(),
        percentage: json["percentage"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "completed_days": completedDays,
        "total_days": totalDays,
        "percentage": percentage,
      };
}
