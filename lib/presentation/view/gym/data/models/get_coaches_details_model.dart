import 'dart:convert';

GetCoachesDetailsModel getCoachesListModelFromJson(String str) => GetCoachesDetailsModel.fromJson(json.decode(str));

String getCoachesListModelToJson(GetCoachesDetailsModel data) => json.encode(data.toJson());

class GetCoachesDetailsModel {
  String? status;
  CoachesDetails? data;
  String? message;

  GetCoachesDetailsModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetCoachesDetailsModel.fromJson(Map<String, dynamic> json) => GetCoachesDetailsModel(
        status: json["status"],
        data: json["data"] == null ? null : CoachesDetails.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
        "message": message,
      };
}

class CoachesDetails {
  CoachInfo? coachInfo;
  List<Availability>? availability;

  CoachesDetails({
    this.coachInfo,
    this.availability,
  });

  factory CoachesDetails.fromJson(Map<String, dynamic> json) => CoachesDetails(
        coachInfo: json["coach_info"] == null ? null : CoachInfo.fromJson(json["coach_info"]),
        availability: json["availability"] == null
            ? []
            : List<Availability>.from(json["availability"]!.map((x) => Availability.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "coach_info": coachInfo?.toJson(),
        "availability": availability == null ? [] : List<dynamic>.from(availability!.map((x) => x.toJson())),
      };
}

class Availability {
  String? dayOfWeek;
  String? fromTime;
  String? toTime;
  String? addressArea;
  String? slot;

  Availability({
    this.dayOfWeek,
    this.fromTime,
    this.toTime,
    this.addressArea,
    this.slot,
  });

  factory Availability.fromJson(Map<String, dynamic> json) => Availability(
        dayOfWeek: json["day_of_week"],
        fromTime: json["from_time"],
        toTime: json["to_time"],
        addressArea: json["address_area"],
        slot: json["slot"],
      );

  Map<String, dynamic> toJson() => {
        "day_of_week": dayOfWeek,
        "from_time": fromTime,
        "to_time": toTime,
        "address_area": addressArea,
        "slot": slot,
      };
}

class CoachInfo {
  String? id;
  String? fullName;
  String? profilePhoto;
  String? dob;
  String? gender;
  String? address;
  String? contactNumber;
  String? countryName;
  String? experienceYears;
  String? levels;

  CoachInfo({
    this.id,
    this.fullName,
    this.profilePhoto,
    this.dob,
    this.gender,
    this.address,
    this.contactNumber,
    this.countryName,
    this.experienceYears,
    this.levels,
  });

  factory CoachInfo.fromJson(Map<String, dynamic> json) => CoachInfo(
        id: json["id"],
        fullName: json["full_name"],
        profilePhoto: json["profile_photo"],
        dob: json["dob"],
        gender: json["gender"],
        address: json["address"],
        contactNumber: json["contact_number"],
        countryName: json["country_name"],
        experienceYears: json["experience_years"],
        levels: json["levels"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "profile_photo": profilePhoto,
        "dob": dob,
        "gender": gender,
        "address": address,
        "contact_number": contactNumber,
        "country_name": countryName,
        "experience_years": experienceYears,
        "levels": levels,
      };
}
