import 'dart:convert';

GetLifeStyleResultModel getLifeStyleResultModelFromJson(String str) =>
    GetLifeStyleResultModel.fromJson(json.decode(str));

String getLifeStyleResultModelToJson(GetLifeStyleResultModel data) => json.encode(data.toJson());

class GetLifeStyleResultModel {
  String? status;
  int? score;
  Summary? summary;
  String? message;

  GetLifeStyleResultModel({
    this.status,
    this.score,
    this.summary,
    this.message,
  });

  factory GetLifeStyleResultModel.fromJson(Map<String, dynamic> json) => GetLifeStyleResultModel(
        status: json["status"],
        score: json["score"],
        summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "score": score,
        "summary": summary?.toJson(),
        "message": message,
      };
}

class Summary {
  String? range;
  String? label;

  Summary({
    this.range,
    this.label,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        range: json["range"],
        label: json["label"],
      );

  Map<String, dynamic> toJson() => {
        "range": range,
        "label": label,
      };
}
