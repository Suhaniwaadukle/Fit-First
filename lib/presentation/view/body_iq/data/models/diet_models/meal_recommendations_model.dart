class MealRecommendationsResponse {
  final String status;
  final String meal;
  final int targetCalories;
  final List<FoodRecommendation> items;

  MealRecommendationsResponse({
    required this.status,
    required this.meal,
    required this.targetCalories,
    required this.items,
  });

  factory MealRecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return MealRecommendationsResponse(
      status: json['status'] ?? '',
      meal: json['meal'] ?? '',
      targetCalories: json['target_calories'] ?? 0,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => FoodRecommendation.fromJson(item))
          .toList() ?? [],
    );
  }
}

// ✅ UPDATED: Added image field
class FoodRecommendation {
  final String itemId;
  final String itemName;
  final String quantity;
  final String protein;
  final String carbs;
  final String fats;
  final String? image; // ✅ ADDED: Image field
  final int calories;

  FoodRecommendation({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.image, // ✅ ADDED: Image field
    required this.calories,
  });

  factory FoodRecommendation.fromJson(Map<String, dynamic> json) {
    return FoodRecommendation(
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? '',
      protein: json['protein']?.toString() ?? '0',
      carbs: json['carbs']?.toString() ?? '0',
      fats: json['fats']?.toString() ?? '0',
      image: json['image']?.toString(), // ✅ ADDED: Parse image from JSON
      calories: json['calories'] ?? 0,
    );
  }

  // ✅ ADDED: Helper method to check if image is valid
  bool get hasValidImage {
    return image != null && image!.isNotEmpty && !image!.endsWith('/');
  }

  // ✅ ADDED: Equality and hashCode for proper list operations
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodRecommendation && 
           other.itemId == itemId &&
           other.itemName == itemName;
  }

  @override
  int get hashCode => itemId.hashCode ^ itemName.hashCode;
}

// ✅ IMPROVED: Better type handling for MealItem
class MealItem {
  final String userId;
  final String meal;
  final String day;
  final int itemId;
  final String itemName;
  final String quantity;
  final String protein;
  final String carbs;
  final String fats;
  final int calories;
  final String createdAt;
  final String updatedAt;

  MealItem({
    required this.userId,
    required this.meal,
    required this.day,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      userId: json['user_id']?.toString() ?? '',
      meal: json['meal'] ?? '',
      day: json['day'] ?? '',
      itemId: int.tryParse(json['item_id']?.toString() ?? '0') ?? 0, // ✅ IMPROVED: Safe parsing
      itemName: json['item_name'] ?? '',
      quantity: json['quantity'] ?? '',
      protein: json['protein']?.toString() ?? '0',
      carbs: json['carbs']?.toString() ?? '0',
      fats: json['fats']?.toString() ?? '0',
      calories: int.tryParse(json['calories']?.toString() ?? '0') ?? 0, // ✅ IMPROVED: Safe parsing
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // ✅ ADDED: Helper method to get total nutritional values
  double get totalMacros => double.parse(protein) + double.parse(carbs) + double.parse(fats);
}

class AddFoodResponse {
  final String status;
  final String message;
  final List<MealItem> addedItems;
  final List<Map<String, dynamic>> skippedItems;

  AddFoodResponse({
    required this.status,
    required this.message,
    required this.addedItems,
    required this.skippedItems,
  });

  factory AddFoodResponse.fromJson(Map<String, dynamic> json) {
    return AddFoodResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      addedItems: (json['added_items'] as List<dynamic>?)
          ?.map((item) => MealItem.fromJson(item))
          .toList() ?? [],
      skippedItems: (json['skipped_items'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList() ?? [],
    );
  }

  // ✅ ADDED: Helper methods
  bool get hasAddedItems => addedItems.isNotEmpty;
  bool get hasSkippedItems => skippedItems.isNotEmpty;
  bool get isSuccess => status.toLowerCase() == 'success';
  
  String get detailedMessage {
    String message = this.message;
    
    if (hasSkippedItems) {
      message += '\n\nSkipped items:';
      for (var skipped in skippedItems) {
        message += '\n• Item ${skipped['item_id']}: ${skipped['reason']}';
      }
    }
    
    return message;
  }
}

// ✅ IMPROVED: Enhanced DailyMealData with better calculations
class DailyMealData {
  final String date;
  final Map<String, MealRecommendationsResponse> mealRecommendations;
  final Map<String, List<MealItem>> selectedMealItems;

  DailyMealData({
    required this.date,
    required this.mealRecommendations,
    required this.selectedMealItems,
  });

  double get totalTargetCalories {
    return mealRecommendations.values.fold(0.0, (sum, meal) => sum + meal.targetCalories);
  }

  double get totalConsumedCalories {
    double total = 0;
    selectedMealItems.forEach((mealType, items) {
      total += items.fold(0.0, (sum, item) => sum + item.calories);
    });
    return total;
  }

  double get remainingCalories => totalTargetCalories - totalConsumedCalories;
  bool get isExceeding => remainingCalories < 0;

  // ✅ ADDED: Nutritional breakdowns
  double get totalProtein {
    double total = 0;
    selectedMealItems.forEach((mealType, items) {
      total += items.fold(0.0, (sum, item) => sum + double.parse(item.protein));
    });
    return total;
  }

  double get totalCarbs {
    double total = 0;
    selectedMealItems.forEach((mealType, items) {
      total += items.fold(0.0, (sum, item) => sum + double.parse(item.carbs));
    });
    return total;
  }

  double get totalFats {
    double total = 0;
    selectedMealItems.forEach((mealType, items) {
      total += items.fold(0.0, (sum, item) => sum + double.parse(item.fats));
    });
    return total;
  }

  // ✅ ADDED: Progress percentages
  double get calorieProgressPercentage {
    if (totalTargetCalories == 0) return 0.0;
    return (totalConsumedCalories / totalTargetCalories).clamp(0.0, 1.0);
  }

  // ✅ ADDED: Meal-specific helpers
  int getMealItemCount(String mealType) {
    return selectedMealItems[mealType]?.length ?? 0;
  }

  double getMealCalories(String mealType) {
    final items = selectedMealItems[mealType] ?? [];
    return items.fold(0.0, (sum, item) => sum + item.calories);
  }

  int getMealTargetCalories(String mealType) {
    return mealRecommendations[mealType]?.targetCalories ?? 0;
  }

  // ✅ ADDED: Validation helper
  bool get isValid {
    return mealRecommendations.isNotEmpty && 
           date.isNotEmpty && 
           DateTime.tryParse(date) != null;
  }
}
