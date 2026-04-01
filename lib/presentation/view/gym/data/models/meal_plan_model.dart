class MealPlanResponse {
  final String status;
  final int calorieTarget;
  final List<MealPlan> data;
  final String message;

  MealPlanResponse({
    required this.status,
    required this.calorieTarget,
    required this.data,
    required this.message,
  });

  factory MealPlanResponse.fromJson(Map<String, dynamic> json) {
    return MealPlanResponse(
      status: json['status']?.toString() ?? '',
      calorieTarget: int.tryParse(json['calorie_target']?.toString() ?? '0') ?? 0,
      data: (json['data'] as List? ?? [])
          .map((item) => MealPlan.fromJson(item))
          .toList(),
      message: json['message']?.toString() ?? '',
    );
  }
}

class MealPlan {
  final int userId;
  final String meal;
  final int percentage;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String createdAt;

  MealPlan({
    required this.userId,
    required this.meal,
    required this.percentage,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.createdAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      meal: json['meal']?.toString() ?? '',
      percentage: int.tryParse(json['percentage']?.toString() ?? '0') ?? 0,
      calories: int.tryParse(json['calories']?.toString() ?? '0') ?? 0,
      protein: int.tryParse(json['protein']?.toString() ?? '0') ?? 0,
      carbs: int.tryParse(json['carbs']?.toString() ?? '0') ?? 0,
      fats: int.tryParse(json['fats']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
