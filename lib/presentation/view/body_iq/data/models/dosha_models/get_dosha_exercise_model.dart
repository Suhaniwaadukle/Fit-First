import 'dart:convert';

GetDoshaRecoExerciseModel getDoshaRecoExerciseModelFromJson(String str) =>
    GetDoshaRecoExerciseModel.fromJson(json.decode(str));

String getDoshaRecoExerciseModelToJson(GetDoshaRecoExerciseModel data) => json.encode(data.toJson());

class GetDoshaRecoExerciseModel {
  String? status;
  String? dosha;
  List<Meditation>? meditation;
  String? message;

  GetDoshaRecoExerciseModel({
    this.status,
    this.dosha,
    this.meditation,
    this.message,
  });

  factory GetDoshaRecoExerciseModel.fromJson(Map<String, dynamic> json) => GetDoshaRecoExerciseModel(
        status: json["status"],
        dosha: json["dosha"],
        meditation: json["meditation"] == null
            ? []
            : List<Meditation>.from(json["meditation"]!.map((x) => Meditation.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "dosha": dosha,
        "meditation": meditation == null ? [] : List<dynamic>.from(meditation!.map((x) => x.toJson())),
        "message": message,
      };
}

class Meditation {
  String? id;
  String? dosha;
  String? exercisePlan;

  Meditation({
    this.id,
    this.dosha,
    this.exercisePlan,
  });

  factory Meditation.fromJson(Map<String, dynamic> json) => Meditation(
        id: json["id"],
        dosha: json["dosha"],
        exercisePlan: json["exercise_plan"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dosha": dosha,
        "exercise_plan": exercisePlan,
      };
}
