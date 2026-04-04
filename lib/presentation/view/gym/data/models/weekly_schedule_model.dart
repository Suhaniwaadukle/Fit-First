class WeeklyScheduleModel {
  final Map<String, List<String>> workouts;
  final Map<String, String> fromTimes;
  final Map<String, String> toTimes;

  WeeklyScheduleModel({
    required this.workouts,
    required this.fromTimes,
    required this.toTimes,
  });

  Map<String, dynamic> toJson() {
    return {
      "workouts": workouts,
      "fromTimes": fromTimes,
      "toTimes": toTimes,
    };
  }

  factory WeeklyScheduleModel.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleModel(
      workouts: Map<String, List<String>>.from(
        json["workouts"].map(
              (k, v) => MapEntry(k, List<String>.from(v)),
        ),
      ),
      fromTimes: Map<String, String>.from(json["fromTimes"]),
      toTimes: Map<String, String>.from(json["toTimes"]),
    );
  }
}