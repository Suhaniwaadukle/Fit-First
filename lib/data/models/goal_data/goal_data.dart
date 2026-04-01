import 'dart:developer';

// Represents a single goal object
class GoalData {
final String? id; // Unique ID from the server (e.g., "27"), used as 'goalID' in update requests
  final String userId;
  final String goalName;
  final String goalStep;
  final String goalKm; // Corresponds to 'goal_km' in API
  final String? createdAt;
  final String? updatedAt;

  GoalData({
    this.id,
    required this.userId,
    required this.goalName,
    required this.goalStep,
    required this.goalKm,
    this.createdAt,
    this.updatedAt,
  });

  factory GoalData.fromJson(Map<String, dynamic> json) {
    return GoalData(
      id: json['id']?.toString() ?? json['goal_id']?.toString(),
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      goalName: json['goal_name']?.toString() ?? '',
      goalStep: json['goal_step']?.toString() ?? '',
      goalKm: json['goal_km']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  // Generates a map of fields for the 'manageGoals' API request (form-data)
  Map<String, String> toApiRequestFields() {
    final Map<String, String> fields = {
      'userId': userId,
      'goalName': goalName,
      'goalStep': goalStep,
      'goal_km': goalKm,
      // MODIFICATION: Always include goalID.
      // If 'id' is null or empty (creating a new goal), send an empty string for 'goalID'.
      // If 'id' is present (updating an existing goal), send its value.
      'goalID': (id != null && id!.isNotEmpty) ? id! : "", 
    };
    return fields;
  }
}

// Response model for the manageGoals API (POST)
class ManageGoalResponse {
  final String status;
  final String message;
  final GoalData? data; // Optional: if API returns the created/updated goal object

  ManageGoalResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ManageGoalResponse.fromJson(Map<String, dynamic> json) {
    return ManageGoalResponse(
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString() ?? 'Unknown error',
      // API might return the affected/created goal data
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? GoalData.fromJson(json['data'])
          : null,
    );
  }
}

// Response model for the getmanageGoals API (GET)
class GetGoalsResponse {
  final String status;
  final List<GoalData>? data;
  final String message;

  GetGoalsResponse({
    required this.status,
    this.data,
    required this.message,
  });

  factory GetGoalsResponse.fromJson(Map<String, dynamic> json) {
    List<GoalData>? goals;
    if (json['data'] != null && json['data'] is List) {
      try {
        goals = List<GoalData>.from(
            (json['data'] as List).map((x) => GoalData.fromJson(x as Map<String,dynamic>)));
      } catch (e) {
        log("Error parsing list of goals: $e. Data: ${json['data']}");
        goals = []; // Default to empty list on parsing error
      }
    } else if (json['data'] != null) {
      log("Warning: 'data' field in GetGoalsResponse was expected to be a List but received ${json['data'].runtimeType}. Raw: ${json['data']}");
      goals = []; // Default to empty list if data is not a list
    }

    return GetGoalsResponse(
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString() ?? 'No message provided',
      data: goals,
    );
  }
}