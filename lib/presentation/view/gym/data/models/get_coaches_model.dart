import 'dart:convert';

GetCoachesListModel getCoachesListModelFromJson(String str) => GetCoachesListModel.fromJson(json.decode(str));

String getCoachesListModelToJson(GetCoachesListModel data) => json.encode(data.toJson());

class GetCoachesListModel {
  String? status;
  int? count;
  List<CoachesList>? data;
  String? message;

  GetCoachesListModel({
    this.status,
    this.count,
    this.data,
    this.message,
  });

  factory GetCoachesListModel.fromJson(Map<String, dynamic> json) => GetCoachesListModel(
        status: json["status"],
        count: json["count"],
        data: json["data"] == null ? [] : List<CoachesList>.from(json["data"]!.map((x) => CoachesList.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "count": count,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class CoachesList {
  String? id;
  String? fullName;
  String? profilePhoto;
  String? partnerName;
  String? experienceYears;
  String? levels;

  CoachesList({
    this.id,
    this.fullName,
    this.profilePhoto,
    this.partnerName,
    this.experienceYears,
    this.levels,
  });

  factory CoachesList.fromJson(Map<String, dynamic> json) => CoachesList(
        id: json["id"],
        fullName: json["full_name"],
        profilePhoto: json["profile_photo"],
        partnerName: json["partner_name"],
        experienceYears: json["experience_years"],
        levels: json["levels"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "profile_photo": profilePhoto,
        "partner_name": partnerName,
        "experience_years": experienceYears,
        "levels": levels,
      };
}
