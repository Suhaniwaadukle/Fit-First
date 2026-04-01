class BmiApiResponseModel {
  final String userId;
  final double bmi;
  final String bmiCategory;
  final double wHRatio;
  final String recommendedSteps;
  final int bmr;
  final int tdee;
  final int calorieTarget;
  final String goal;
  final int protein;
  final int fat;
  final int carbohydrate;
  final int detailedTdee;
  final double waterIntakeLiters;

  BmiApiResponseModel({
    required this.userId,
    required this.bmi,
    required this.bmiCategory,
    required this.wHRatio,
    required this.recommendedSteps,
    required this.bmr,
    required this.tdee,
    required this.calorieTarget,
    required this.goal,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.detailedTdee,
     required this.waterIntakeLiters,
  });

  factory BmiApiResponseModel.fromJson(Map<String, dynamic> json) {
    return BmiApiResponseModel(
      userId: json['user_id'],
      bmi: (json['bmi'] as num).toDouble(),
      bmiCategory: json['bmi_category'],
      wHRatio: (json['w_h_ratio'] as num).toDouble(),
      recommendedSteps: json['recommended_steps'],
      bmr: (json['bmr'] as num).toInt(),
      tdee: (json['tdee'] as num).toInt(),
      calorieTarget: (json['calorie_target'] as num).toInt(),
      goal: json['goal'],
      protein: (json['protein'] as num).toInt(),
      fat: (json['fat'] as num).toInt(),
      carbohydrate: (json['carbohydrate'] as num).toInt(),
      detailedTdee: (json['deta_vd'] as num).toInt(),
       waterIntakeLiters: (json['water_intake_liters'] as num).toDouble(),
    );
  }
}
