import 'dart:convert';

GoogleRegisterResponse googleRegisterResponseFromJson(String str) => GoogleRegisterResponse.fromJson(json.decode(str));

String googleRegisterResponseToJson(GoogleRegisterResponse data) => json.encode(data.toJson());

class GoogleRegisterResponse {
  String? status;
  String? insertLastId;
  GoogleResponseData? data;
  String? message;
  final String? refreshToken;
   String? token; 

  GoogleRegisterResponse({
    this.status,
    this.insertLastId,
    this.data,
    this.message,
    this.refreshToken,
    this.token,
  });

  factory GoogleRegisterResponse.fromJson(Map<String, dynamic> json) => GoogleRegisterResponse(
        status: json["status"],
        insertLastId: json["insertLast_Id"],
        data: json["data"] == null ? null : GoogleResponseData.fromJson(json["data"]),
        message: json["message"],
        refreshToken: json["refresh_token"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "insertLast_Id": insertLastId,
        "data": data?.toJson(),
        "message": message,
        "token": token, 
      };
}

class GoogleResponseData {
  String? name;
  String? uniqueId;
  String? email;
  String? googleId;
  String? registeredVia;
  int? isVerified;
  String? pictureImage;
   String? token;

  GoogleResponseData({
    this.name,
    this.uniqueId,
    this.email,
    this.googleId,
    this.registeredVia,
    this.isVerified,
    this.pictureImage,
     this.token,
  });

  factory GoogleResponseData.fromJson(Map<String, dynamic> json) => GoogleResponseData(
        name: json["name"],
        uniqueId: json["unique_id"],
        email: json["email"],
        googleId: json["google_id"],
        registeredVia: json["registered_via"],
        isVerified: json["is_verified"],
        pictureImage: json["picture_image"],
         token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "unique_id": uniqueId,
        "email": email,
        "google_id": googleId,
        "registered_via": registeredVia,
        "is_verified": isVerified,
        "picture_image": pictureImage,
        "token": token,
      };
}
