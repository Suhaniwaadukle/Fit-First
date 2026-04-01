import 'dart:convert';

GetGymGoalsModel getGymGoalsModelFromJson(String str) => GetGymGoalsModel.fromJson(json.decode(str));

String getGymGoalsModelToJson(GetGymGoalsModel data) => json.encode(data.toJson());

class GetGymGoalsModel {
  String? status;
  Data? data;
  String? message;

  GetGymGoalsModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetGymGoalsModel.fromJson(Map<String, dynamic> json) => GetGymGoalsModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
        "message": message,
      };
}

class Data {
  String? id;
  String? userId;
  dynamic partnerId;
  String? fitnessGoal;
  String? experienceLevel;
  String? communicationStyle;
  String? genderPreferenceForBuddy;
  String? buddyStatus;
  String? status;
  DateTime? joinDate;
  DateTime? expiredDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.userId,
    this.partnerId,
    this.fitnessGoal,
    this.experienceLevel,
    this.communicationStyle,
    this.genderPreferenceForBuddy,
    this.buddyStatus,
    this.status,
    this.joinDate,
    this.expiredDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        userId: json["user_id"],
        partnerId: json["partner_id"],
        fitnessGoal: json["fitness_goal"],
        experienceLevel: json["experience_level"],
        communicationStyle: json["communication_style"],
        genderPreferenceForBuddy: json["gender_preference_for_buddy"],
        buddyStatus: json["buddy_status"],
        status: json["status"],
        joinDate: json["join_date"] == null ? null : DateTime.parse(json["join_date"]),
        expiredDate: json["expired_date"] == null ? null : DateTime.parse(json["expired_date"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "partner_id": partnerId,
        "fitness_goal": fitnessGoal,
        "experience_level": experienceLevel,
        "communication_style": communicationStyle,
        "gender_preference_for_buddy": genderPreferenceForBuddy,
        "buddy_status": buddyStatus,
        "status": status,
        "join_date":
            "${joinDate!.year.toString().padLeft(4, '0')}-${joinDate!.month.toString().padLeft(2, '0')}-${joinDate!.day.toString().padLeft(2, '0')}",
        "expired_date":
            "${expiredDate!.year.toString().padLeft(4, '0')}-${expiredDate!.month.toString().padLeft(2, '0')}-${expiredDate!.day.toString().padLeft(2, '0')}",
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
