import 'dart:convert';

GetGymDetailsModel getGymDetailsModelFromJson(String str) => GetGymDetailsModel.fromJson(json.decode(str));

String getGymDetailsModelToJson(GetGymDetailsModel data) => json.encode(data.toJson());

class GetGymDetailsModel {
  String? status;
  GymDetailsData? data;
  String? message;

  GetGymDetailsModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetGymDetailsModel.fromJson(Map<String, dynamic> json) => GetGymDetailsModel(
        status: json["status"],
        data: json["data"] == null ? null : GymDetailsData.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
        "message": message,
      };
}

class GymDetailsData {
  String? id;
  String? name;
  String? email;
  String? phonecode;
  String? mobile;
  String? locationUrl;
  String? address;
  String? description;
  String? startTimeMonday;
  String? endTimeMonday;
  String? startTimeTuesday;
  String? endTimeTuesday;
  String? startTimeWednesday;
  String? endTimeWednesday;
  String? startTimeThursday;
  String? endTimeThursday;
  String? startTimeFriday;
  String? endTimeFriday;
  String? startTimeSaturday;
  String? endTimeSaturday;
  String? startTimeSunday;
  String? endTimeSunday;
  String? features;
  String? partnerImage;
  List<String>? gallery;

  GymDetailsData({
    this.id,
    this.name,
    this.email,
    this.phonecode,
    this.mobile,
    this.locationUrl,
    this.address,
    this.description,
    this.startTimeMonday,
    this.endTimeMonday,
    this.startTimeTuesday,
    this.endTimeTuesday,
    this.startTimeWednesday,
    this.endTimeWednesday,
    this.startTimeThursday,
    this.endTimeThursday,
    this.startTimeFriday,
    this.endTimeFriday,
    this.startTimeSaturday,
    this.endTimeSaturday,
    this.startTimeSunday,
    this.endTimeSunday,
    this.features,
    this.partnerImage,
    this.gallery,
  });

  factory GymDetailsData.fromJson(Map<String, dynamic> json) => GymDetailsData(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phonecode: json["phonecode"],
        mobile: json["mobile"],
        locationUrl: json["location_url"],
        address: json["address"],
        description: json["description"],
        startTimeMonday: json["start_time_monday"],
        endTimeMonday: json["end_time_monday"],
        startTimeTuesday: json["start_time_tuesday"],
        endTimeTuesday: json["end_time_tuesday"],
        startTimeWednesday: json["start_time_wednesday"],
        endTimeWednesday: json["end_time_wednesday"],
        startTimeThursday: json["start_time_thursday"],
        endTimeThursday: json["end_time_thursday"],
        startTimeFriday: json["start_time_friday"],
        endTimeFriday: json["end_time_friday"],
        startTimeSaturday: json["start_time_saturday"],
        endTimeSaturday: json["end_time_saturday"],
        startTimeSunday: json["start_time_sunday"],
        endTimeSunday: json["end_time_sunday"],
        features: json["features"],
        partnerImage: json["partner_image"],
        gallery: json["gallery"] == null ? [] : List<String>.from(json["gallery"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phonecode": phonecode,
        "mobile": mobile,
        "location_url": locationUrl,
        "address": address,
        "description": description,
        "start_time_monday": startTimeMonday,
        "end_time_monday": endTimeMonday,
        "start_time_tuesday": startTimeTuesday,
        "end_time_tuesday": endTimeTuesday,
        "start_time_wednesday": startTimeWednesday,
        "end_time_wednesday": endTimeWednesday,
        "start_time_thursday": startTimeThursday,
        "end_time_thursday": endTimeThursday,
        "start_time_friday": startTimeFriday,
        "end_time_friday": endTimeFriday,
        "start_time_saturday": startTimeSaturday,
        "end_time_saturday": endTimeSaturday,
        "start_time_sunday": startTimeSunday,
        "end_time_sunday": endTimeSunday,
        "features": features,
        "partner_image": partnerImage,
        "gallery": gallery == null ? [] : List<dynamic>.from(gallery!.map((x) => x)),
      };
}
