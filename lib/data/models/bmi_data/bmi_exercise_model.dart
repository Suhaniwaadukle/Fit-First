class WalkRecommendationModel {
  final String id;
  final String bmiCategory;
  final String goal;
  final String recommendedDistanceKm;
  final String pace;
  final String notes;

  WalkRecommendationModel({
    required this.id,
    required this.bmiCategory,
    required this.goal,
    required this.recommendedDistanceKm,
    required this.pace,
    required this.notes,
  });

  factory WalkRecommendationModel.fromJson(Map<String, dynamic> json) {
    return WalkRecommendationModel(
      id: json['id'],
      bmiCategory: json['bmi_category'],
      goal: json['goal'],
      recommendedDistanceKm: json['recommended_distance_km'],
      pace: json['pace'],
      notes: json['notes'],
    );
  }
}

class RunRecommendationModel {
  final String id;
  final String bmiCategory;
  final String fitnessGoal;
  final String recommendedRunPerDay;
  final String runFrequency;
  final String notes;

  RunRecommendationModel({
    required this.id,
    required this.bmiCategory,
    required this.fitnessGoal,
    required this.recommendedRunPerDay,
    required this.runFrequency,
    required this.notes,
  });

  factory RunRecommendationModel.fromJson(Map<String, dynamic> json) {
    return RunRecommendationModel(
      id: json['id'],
      bmiCategory: json['bmi_category'],
      fitnessGoal: json['fitness_goal'],
      recommendedRunPerDay: json['recommended_run_per_day'],
      runFrequency: json['run_frequency'],
      notes: json['notes'],
    );
  }
}

class CyclingRecommendationModel {
  final String id;
  final String bmiCategory;
  final String fitnessGoal;
  final String recommendedDistancePerDay;
  final String frequency;
  final String notes;

  CyclingRecommendationModel({
    required this.id,
    required this.bmiCategory,
    required this.fitnessGoal,
    required this.recommendedDistancePerDay,
    required this.frequency,
    required this.notes,
  });

  factory CyclingRecommendationModel.fromJson(Map<String, dynamic> json) {
    return CyclingRecommendationModel(
      id: json['id'],
      bmiCategory: json['bmi_category'],
      fitnessGoal: json['fitness_goal'],
      recommendedDistancePerDay: json['recommended_distance_per_day'],
      frequency: json['frequency'],
      notes: json['notes'],
    );
  }
}
