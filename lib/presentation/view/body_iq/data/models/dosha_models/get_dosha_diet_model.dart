import 'dart:convert';

GetDoshaRecoDietModel getDoshaRecoDietModelFromJson(String str) => GetDoshaRecoDietModel.fromJson(json.decode(str));

String getDoshaRecoDietModelToJson(GetDoshaRecoDietModel data) => json.encode(data.toJson());

class GetDoshaRecoDietModel {
  String? status;
  String? dosha;
  Meals? meals;
  String? message;

  GetDoshaRecoDietModel({
    this.status,
    this.dosha,
    this.meals,
    this.message,
  });

  factory GetDoshaRecoDietModel.fromJson(Map<String, dynamic> json) => GetDoshaRecoDietModel(
        status: json["status"],
        dosha: json["dosha"],
        meals: json["meals"] == null ? null : Meals.fromJson(json["meals"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "dosha": dosha,
        "meals": meals?.toJson(),
        "message": message,
      };
}

class Meals {
  List<Breakfast>? breakfast;
  List<Breakfast>? lunch;
  List<Breakfast>? dinner;

  Meals({
    this.breakfast,
    this.lunch,
    this.dinner,
  });

  factory Meals.fromJson(Map<String, dynamic> json) => Meals(
        breakfast:
            json["breakfast"] == null ? [] : List<Breakfast>.from(json["breakfast"]!.map((x) => Breakfast.fromJson(x))),
        lunch: json["lunch"] == null ? [] : List<Breakfast>.from(json["lunch"]!.map((x) => Breakfast.fromJson(x))),
        dinner: json["dinner"] == null ? [] : List<Breakfast>.from(json["dinner"]!.map((x) => Breakfast.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "breakfast": breakfast == null ? [] : List<dynamic>.from(breakfast!.map((x) => x.toJson())),
        "lunch": lunch == null ? [] : List<dynamic>.from(lunch!.map((x) => x.toJson())),
        "dinner": dinner == null ? [] : List<dynamic>.from(dinner!.map((x) => x.toJson())),
      };
}

class Breakfast {
  String? dish;
  bool? isVeg;

  Breakfast({
    this.dish,
    this.isVeg,
  });

  factory Breakfast.fromJson(Map<String, dynamic> json) => Breakfast(
        dish: json["dish"],
        isVeg: json["is_veg"],
      );

  Map<String, dynamic> toJson() => {
        "dish": dish,
        "is_veg": isVeg,
      };
}
