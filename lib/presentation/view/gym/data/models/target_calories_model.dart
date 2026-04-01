class TargetCaloriesResponse {
  final String status;
  final int calorieTarget;
  final String message;

  TargetCaloriesResponse({
    required this.status,
    required this.calorieTarget,
    required this.message,
  });

  factory TargetCaloriesResponse.fromJson(Map<String, dynamic> json) {
    return TargetCaloriesResponse(
      status: json['status']?.toString() ?? '',
      calorieTarget: int.tryParse(json['calorie_target']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}
