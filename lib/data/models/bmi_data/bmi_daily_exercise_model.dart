class DailyWalkRecommendationModel {
  final String bmiCategory;
  final String goal;
  final String recommendedDistanceKm;
  final String pace;
  final String notes;
  final int recommendedKm;
  final int actualKmToday;
  final bool popupRequired;
  final int coinsAwardedToday;
  final int weeklyReward;
  final int monthlyReward;

  DailyWalkRecommendationModel({
    required this.bmiCategory,
    required this.goal,
    required this.recommendedDistanceKm,
    required this.pace,
    required this.notes,
    required this.recommendedKm,
    required this.actualKmToday,
    required this.popupRequired,
    required this.coinsAwardedToday,
    required this.weeklyReward,
    required this.monthlyReward,
  });

  factory DailyWalkRecommendationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DailyWalkRecommendationModel(
      bmiCategory: data['bmi_category'] ?? '',
      goal: data['goal'] ?? '',
      recommendedDistanceKm: data['recommended_distance_km'] ?? '',
      pace: data['pace'] ?? '',
      notes: data['notes'] ?? '',
      recommendedKm: json['recommended_km'] ?? 0,
      actualKmToday: (json['actual_km_today'] as num?)?.toInt() ?? 0,
      popupRequired: json['popup_required'] ?? false,
      coinsAwardedToday: json['coins_awarded_today'] ?? 0,
      weeklyReward: json['weekly_reward'] ?? 0,
      monthlyReward: json['monthly_reward'] ?? 0,
    );
  }
}

class DailyRunRecommendationModel {
  final String bmiCategory;
  final String fitnessGoal;
  final String recommendedRunPerDay;
  final String runFrequency;
  final String notes;
  final int recommendedKm;
  final double actualKmToday;
  final bool popupRequired;
  final int coinsAwardedToday;
  final int weeklyReward;
  final int monthlyReward;

  DailyRunRecommendationModel({
    required this.bmiCategory,
    required this.fitnessGoal,
    required this.recommendedRunPerDay,
    required this.runFrequency,
    required this.notes,
    required this.recommendedKm,
    required this.actualKmToday,
    required this.popupRequired,
    required this.coinsAwardedToday,
    required this.weeklyReward,
    required this.monthlyReward,
  });

  factory DailyRunRecommendationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DailyRunRecommendationModel(
      bmiCategory: data['bmi_category'] ?? '',
      fitnessGoal: data['fitness_goal'] ?? '',
      recommendedRunPerDay: data['recommended_run_per_day'] ?? '',
      runFrequency: data['run_frequency'] ?? '',
      notes: data['notes'] ?? '',
      recommendedKm: json['recommended_km'] ?? 0,
      actualKmToday: (json['actual_km_today'] as num?)?.toDouble() ?? 0.0,
      popupRequired: json['popup_required'] ?? false,
      coinsAwardedToday: json['coins_awarded_today'] ?? 0,
      weeklyReward: json['weekly_reward'] ?? 0,
      monthlyReward: json['monthly_reward'] ?? 0,
    );
  }
}

class DailyCyclingRecommendationModel {
  final String bmiCategory;
  final String goal;
  final String recommendedDistanceKm;
  final String frequency;
  final String notes;
  final int recommendedKm;
  final double actualKmToday;
  final bool popupRequired;
  final int coinsAwardedToday;
  final int weeklyReward;
  final int monthlyReward;

  DailyCyclingRecommendationModel({
    required this.bmiCategory,
    required this.goal,
    required this.recommendedDistanceKm,
    required this.frequency,
    required this.notes,
    required this.recommendedKm,
    required this.actualKmToday,
    required this.popupRequired,
    required this.coinsAwardedToday,
    required this.weeklyReward,
    required this.monthlyReward,
  });

  factory DailyCyclingRecommendationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DailyCyclingRecommendationModel(
      bmiCategory: data['bmi_category'] ?? '',
      goal: data['goal'] ?? '',
      recommendedDistanceKm: data['recommended_distance_km'] ?? '',
      frequency: data['frequency'] ?? '',
      notes: data['notes'] ?? '',
      recommendedKm: json['recommended_km'] ?? 0,
      actualKmToday: (json['actual_km_today'] as num?)?.toDouble() ?? 0.0,
      popupRequired: json['popup_required'] ?? false,
      coinsAwardedToday: json['coins_awarded_today'] ?? 0,
      weeklyReward: json['weekly_reward'] ?? 0,
      monthlyReward: json['monthly_reward'] ?? 0,
    );
  }
}

class DailyHikingRecommendationModel {
  final String bmiCategory;
  final String goal;
  final String recommendedDistanceKm;
  final String frequency;
  final String notes;
  final int recommendedKm;
  final double actualKmToday;
  final bool popupRequired;
  final int coinsAwardedToday;
  final int weeklyReward;
  final int monthlyReward;

  DailyHikingRecommendationModel({
    required this.bmiCategory,
    required this.goal,
    required this.recommendedDistanceKm,
    required this.frequency,
    required this.notes,
    required this.recommendedKm,
    required this.actualKmToday,
    required this.popupRequired,
    required this.coinsAwardedToday,
    required this.weeklyReward,
    required this.monthlyReward,
  });

  factory DailyHikingRecommendationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DailyHikingRecommendationModel(
      bmiCategory: data['bmi_category'] ?? '',
      goal: data['goal'] ?? '',
      recommendedDistanceKm: data['recommended_distance_km'] ?? '',
      frequency: data['frequency'] ?? '',
      notes: data['notes'] ?? '',
      recommendedKm: json['recommended_km'] ?? 0,
      actualKmToday: (json['actual_km_today'] as num?)?.toDouble() ?? 0.0,
      popupRequired: json['popup_required'] ?? false,
      coinsAwardedToday: json['coins_awarded_today'] ?? 0,
      weeklyReward: json['weekly_reward'] ?? 0,
      monthlyReward: json['monthly_reward'] ?? 0,
    );
  }
}
