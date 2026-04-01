import 'dart:convert';

GetAllUsersModel gelAllUsersModelFromJson(String str) => GetAllUsersModel.fromJson(json.decode(str));

String gelAllUsersModelToJson(GetAllUsersModel data) => json.encode(data.toJson());

class GetAllUsersModel {
  String? status;
  List<AllUsersModel>? data;
  String? message;

  GetAllUsersModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetAllUsersModel.fromJson(Map<String, dynamic> json) => GetAllUsersModel(
        status: json["status"],
        data: json["data"] == null ? [] : List<AllUsersModel>.from(json["data"]!.map((x) => AllUsersModel.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class AllUsersModel {
  String? userId;
  String? userName;
  String? userProfile;
  String? userLat;
  String? userLong;

  AllUsersModel({
    this.userId,
    this.userName,
    this.userProfile,
    this.userLat,
    this.userLong,
  });

  factory AllUsersModel.fromJson(Map<String, dynamic> json) => AllUsersModel(
        userId: json["UserID"],
        userName: json["UserName"],
        userProfile: json["UserProfile"],
        userLat: json["UserLat"] ?? "",
        userLong: json["UserLong"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "UserID": userId,
        "UserName": userName,
        "UserProfile": userProfile,
        "UserLat": userLat,
        "UserLong": userLong,
      };
}
