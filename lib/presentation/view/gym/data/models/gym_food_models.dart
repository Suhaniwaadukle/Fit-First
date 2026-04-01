class GymFoodRecommendation {
  final String itemId;
  final String itemName;
  final String quantity;
  final String protein;
  final String carbs;
  final String fats;
  final int calories;
  final String image; // ✅ ADD this field

  GymFoodRecommendation({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
    required this.image, // ✅ ADD this parameter
  });

  factory GymFoodRecommendation.fromJson(Map<String, dynamic> json) {
    return GymFoodRecommendation(
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      protein: json['protein']?.toString() ?? '',
      carbs: json['carbs']?.toString() ?? '',
      fats: json['fats']?.toString() ?? '',
      calories: json['calories'] ?? 0,
      image: json['image']?.toString() ?? '', // ✅ ADD this line
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymFoodRecommendation &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId;

  @override
  int get hashCode => itemId.hashCode;
}

// Keep GymMealRecommendationsResponse class exactly the same
class GymMealRecommendationsResponse {
  final String status;
  final String meal;
  final int targetCalories;
  final List<GymFoodRecommendation> items;

  GymMealRecommendationsResponse({
    required this.status,
    required this.meal,
    required this.targetCalories,
    required this.items,
  });

  factory GymMealRecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return GymMealRecommendationsResponse(
      status: json['status']?.toString() ?? '',
      meal: json['meal']?.toString() ?? '',
      targetCalories: json['target_calories'] ?? 0,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => GymFoodRecommendation.fromJson(item))
          .toList() ?? [],
    );
  }
}
