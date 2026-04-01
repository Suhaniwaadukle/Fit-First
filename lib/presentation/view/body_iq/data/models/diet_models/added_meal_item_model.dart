class AddedMealItem {
  final String id;
  final String userId;
  final String meal;
  final String day;
  final String itemId;
  final String itemName;
  final String quantity;
  final String protein;
  final String carbs;
  final String fats;
  final String calories;
  final String createdAt;
  final String updatedAt;

  AddedMealItem({
    required this.id,
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

  factory AddedMealItem.fromJson(Map<String, dynamic> json) {
    return AddedMealItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      meal: json['meal']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      protein: json['protein']?.toString() ?? '',
      carbs: json['carbs']?.toString() ?? '',
      fats: json['fats']?.toString() ?? '',
      calories: json['calories']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal': meal,
      'day': day,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'calories': calories,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
