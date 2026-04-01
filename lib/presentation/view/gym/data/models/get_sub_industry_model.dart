import 'dart:convert';

GetSubIndustryModel getSubIndustryModelFromJson(String str) => GetSubIndustryModel.fromJson(json.decode(str));

String getSubIndustryModelToJson(GetSubIndustryModel data) => json.encode(data.toJson());

class GetSubIndustryModel {
  String? status;
  List<SubIndustryData>? data;
  String? message;

  GetSubIndustryModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetSubIndustryModel.fromJson(Map<String, dynamic> json) => GetSubIndustryModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<SubIndustryData>.from(json["data"]!.map((x) => SubIndustryData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class SubIndustryData {
  String? id;
  String? name;
  String? icon;
  String? categoryId;

  SubIndustryData({
    this.id,
    this.name,
    this.icon,
    this.categoryId,
  });

  factory SubIndustryData.fromJson(Map<String, dynamic> json) => SubIndustryData(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        categoryId: json["categoryId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "categoryId": categoryId,
      };
}
