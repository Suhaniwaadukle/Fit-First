import 'dart:convert';

GetNearGymModel getNearGymModelFromJson(String str) => GetNearGymModel.fromJson(json.decode(str));

String getNearGymModelToJson(GetNearGymModel data) => json.encode(data.toJson());

class GetNearGymModel {
  String? status;
  int? totalGymList;
  List<NearGymData>? data;
  String? message;

  GetNearGymModel({
    this.status,
    this.totalGymList,
    this.data,
    this.message,
  });

  factory GetNearGymModel.fromJson(Map<String, dynamic> json) => GetNearGymModel(
        status: json["status"],
        totalGymList: json["Total gym list"],
        data: json["data"] == null ? [] : List<NearGymData>.from(json["data"]!.map((x) => NearGymData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "Total gym list": totalGymList,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class NearGymData {
  String? id;
  String? name;
  String? email;
  String? phonecode;
  String? mobile;
  String? partnerImage;
  String? distance;

  NearGymData({
    this.id,
    this.name,
    this.email,
    this.phonecode,
    this.mobile,
    this.partnerImage,
    this.distance,
  });

  factory NearGymData.fromJson(Map<String, dynamic> json) => NearGymData(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phonecode: json["phonecode"],
        mobile: json["mobile"],
        partnerImage: json["partner_image"],
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phonecode": phonecode,
        "mobile": mobile,
        "partner_image": partnerImage,
        "distance": distance,
      };
}
