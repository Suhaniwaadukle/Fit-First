import 'dart:convert';

GetDoshaRecoMeditationModel getDoshaRecoMeditationModelFromJson(String str) =>
    GetDoshaRecoMeditationModel.fromJson(json.decode(str));

String getDoshaRecoMeditationModelToJson(GetDoshaRecoMeditationModel data) => json.encode(data.toJson());

class GetDoshaRecoMeditationModel {
  String? status;
  String? dosha;
  List<Meditation>? meditation;
  String? message;

  GetDoshaRecoMeditationModel({
    this.status,
    this.dosha,
    this.meditation,
    this.message,
  });

  factory GetDoshaRecoMeditationModel.fromJson(Map<String, dynamic> json) => GetDoshaRecoMeditationModel(
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
  String? meditationTechnique;

  Meditation({
    this.id,
    this.dosha,
    this.meditationTechnique,
  });

  factory Meditation.fromJson(Map<String, dynamic> json) => Meditation(
        id: json["id"],
        dosha: json["dosha"],
        meditationTechnique: json["meditation_technique"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dosha": dosha,
        "meditation_technique": meditationTechnique,
      };
}
