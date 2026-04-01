import 'package:flutter/material.dart';

class BmiData {
  final double bmi;
  final String category;
  final double height; // in cm
  final int weight; // in kg
  final int age;
  final String gender;
  final double bmr; // Basal Metabolic Rate
  final double whRatio; // Waist to Hip ratio (calculated estimate)
  final double dailyCalories;
  final double protein; // grams per day
  final double carbohydrates; // grams per day
  final double fat; // grams per day
  final DateTime calculatedAt;

  BmiData({
    required this.bmi,
    required this.category,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.bmr,
    required this.whRatio,
    required this.dailyCalories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.calculatedAt,
  });

  factory BmiData.calculate({
    required double height, // in cm
    required int weight, // in kg
    required int age,
    required String gender,
  }) {
    // Calculate BMI
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    
    // Determine BMI category
    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 25) {
      category = 'Normal';
    } else if (bmi < 30) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Calculate daily calories (BMR * activity factor, using sedentary 1.2)
    final dailyCalories = bmr * 1.2;

    // Calculate macronutrients
    final protein = weight * 0.8; // 0.8g per kg body weight
    final fat = (dailyCalories * 0.25) / 9; // 25% of calories from fat
    final carbohydrates = (dailyCalories - (protein * 4) - (fat * 9)) / 4;

    // Estimate W/H ratio (this is simplified, normally requires waist measurement)
    final whRatio = _estimateWHRatio(bmi, gender);

    return BmiData(
      bmi: double.parse(bmi.toStringAsFixed(1)),
      category: category,
      height: height,
      weight: weight,
      age: age,
      gender: gender,
      bmr: double.parse(bmr.toStringAsFixed(0)),
      whRatio: double.parse(whRatio.toStringAsFixed(1)),
      dailyCalories: double.parse(dailyCalories.toStringAsFixed(0)),
      protein: double.parse(protein.toStringAsFixed(1)),
      carbohydrates: double.parse(carbohydrates.toStringAsFixed(1)),
      fat: double.parse(fat.toStringAsFixed(1)),
      calculatedAt: DateTime.now(),
    );
  }

  static double _estimateWHRatio(double bmi, String gender) {
    // This is a simplified estimation based on BMI
    // In reality, W/H ratio requires actual waist and hip measurements
    if (gender.toLowerCase() == 'male') {
      if (bmi < 18.5) return 0.85;
      if (bmi < 25) return 0.90;
      if (bmi < 30) return 0.95;
      return 1.0;
    } else {
      if (bmi < 18.5) return 0.75;
      if (bmi < 25) return 0.80;
      if (bmi < 30) return 0.85;
      return 0.90;
    }
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'bmi': bmi,
      'category': category,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'bmr': bmr,
      'whRatio': whRatio,
      'dailyCalories': dailyCalories,
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fat': fat,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory BmiData.fromJson(Map<String, dynamic> json) {
    return BmiData(
      bmi: json['bmi']?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
      height: json['height']?.toDouble() ?? 0.0,
      weight: json['weight']?.toInt() ?? 0,
      age: json['age']?.toInt() ?? 0,
      gender: json['gender'] ?? '',
      bmr: json['bmr']?.toDouble() ?? 0.0,
      whRatio: json['whRatio']?.toDouble() ?? 0.0,
      dailyCalories: json['dailyCalories']?.toDouble() ?? 0.0,
      protein: json['protein']?.toDouble() ?? 0.0,
      carbohydrates: json['carbohydrates']?.toDouble() ?? 0.0,
      fat: json['fat']?.toDouble() ?? 0.0,
      calculatedAt: DateTime.parse(json['calculatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Get BMI progress value for circular indicator (0.0 to 1.0)
  double get progressValue {
    // Normalize BMI to 0-1 scale (using range 15-35)
    final normalizedBmi = ((bmi - 15) / 20).clamp(0.0, 1.0);
    return normalizedBmi;
  }

  // Get color based on BMI category
  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'underweight':
        return const Color(0xFF2196F3); // Blue
      case 'normal':
        return const Color(0xFF4CAF50); // Green
      case 'overweight':
        return const Color(0xFFF57C00); // Orange
      case 'obese':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Get exercise recommendations based on BMI category
  List<Map<String, dynamic>> get exerciseRecommendations {
    return [
      {
        "title": "Running",
        "desc": "Maintain cardiovascular health",
        "icon": Icons.directions_run_rounded,
      },
      {
        "title": "Walking",
        "desc": "Improve overall fitness",
        "icon": Icons.directions_walk_rounded,
      },
      {
        "title": "Cycling",
        "desc": "Low-impact cardio exercise",
        "icon": Icons.directions_bike_rounded,
      },
    ];
  }
}