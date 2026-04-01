import 'dart:convert';

GetGymBuddyModel getGymBuddyModelFromJson(String str) => GetGymBuddyModel.fromJson(json.decode(str));

String getGymBuddyModelToJson(GetGymBuddyModel data) => json.encode(data.toJson());

class GetGymBuddyModel {
  String? status;
  List<GymBuddyData>? data;
  String? message;

  GetGymBuddyModel({
    this.status,
    this.data,
    this.message,
  });

  factory GetGymBuddyModel.fromJson(Map<String, dynamic> json) => GetGymBuddyModel(
        status: json["status"],
        data: json["data"] == null ? [] : List<GymBuddyData>.from(json["data"]!.map((x) => GymBuddyData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class GymBuddyData {
  String? id;
  String? name;
  String? image;
  String? age;
  String? fitnessLevel;
  String? avgRating;        
  String? totalFeedbacks;

  GymBuddyData({
    this.id,
    this.name,
    this.image,
    this.age,
    this.fitnessLevel,
    this.avgRating,        
    this.totalFeedbacks,
  });

  factory GymBuddyData.fromJson(Map<String, dynamic> json) => GymBuddyData(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        age: json["age"],
        fitnessLevel: json["fitness_level"],
        avgRating: json["avg_rating"],           
        totalFeedbacks: json["total_feedbacks"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "age": age,
        "fitness_level": fitnessLevel,
        "avg_rating": avgRating,           
        "total_feedbacks": totalFeedbacks,
      };
}
