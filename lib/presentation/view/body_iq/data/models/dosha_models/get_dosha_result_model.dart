import 'dart:convert';

GetDoshaResultModel getDoshaResultModelFromJson(String str) => GetDoshaResultModel.fromJson(json.decode(str));

String getDoshaResultModelToJson(GetDoshaResultModel data) => json.encode(data.toJson());

class GetDoshaResultModel {
  String? status;
  String? message;
  String? vata;
  String? pitta;
  String? kapha;
  String? dominantDosha;

  GetDoshaResultModel({
    this.status,
    this.message,
    this.vata,
    this.pitta,
    this.kapha,
    this.dominantDosha,
  });

  factory GetDoshaResultModel.fromJson(Map<String, dynamic> json) => GetDoshaResultModel(
        status: json["status"],
        message: json["message"],
        vata: json["Vata"].toString(),
        pitta: json["Pitta"].toString(),
        kapha: json["Kapha"].toString(),
        dominantDosha: json["DominantDosha"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "Vata": vata,
        "Pitta": pitta,
        "Kapha": kapha,
        "DominantDosha": dominantDosha,
      };
}
