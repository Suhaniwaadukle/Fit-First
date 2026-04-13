import 'dart:developer';

class GetActivityResponse {
  final String status;
  final List<ActivityData>? data;
  final String message;

  GetActivityResponse({
    required this.status,
    this.data,
    required this.message,
  });

  factory GetActivityResponse.fromJson(Map<String, dynamic> json) {
    return GetActivityResponse(
      status: json['status'],
      data: json['data'] != null
          ? List<ActivityData>.from(
              json['data'].map((x) => ActivityData.fromJson(x)))
          : null,
      message: json['message'],
    );
  }
}

class ActivityData {
  final String? id;
  final String? activityId;
  final String? activityName; 
  final String sourceLat;
  final String userId;
  final String sourceLng;
  final String destinationLat;
  final String destinationLng;
  final String timeTaken;
  final String avgPace;
  final String distance;
  final String overSpeeding;
  final String caloriesBurned;
  final String elevationGain;
  final String? createdAt;

  ActivityData({
    this.id,
    required this.activityId,
    this.activityName,
    required this.sourceLat,
    required this.userId,
    required this.sourceLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.timeTaken,
    required this.avgPace,
    required this.distance,
    required this.overSpeeding,
    required this.caloriesBurned,
    required this.elevationGain,
    this.createdAt,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) => ActivityData(
        id: json['id']?.toString() ,
        activityId: json['activity_id']?.toString(),
        activityName: json['activity_name']?.toString(),
        sourceLat: json['source_lat'].toString(),
        userId: json['userid'].toString(),
        sourceLng: json['source_lng'].toString(),
        destinationLat: json['destination_lat'].toString(),
        destinationLng: json['destination_lng'].toString(),
        timeTaken: json['time_taken'].toString(),
        avgPace: json['avg_pace'].toString(),
        distance: json['distance'].toString(),
        overSpeeding: json['over_speeding'].toString(),
        caloriesBurned: json['calories_burned'].toString(),
        elevationGain: json['elevation_gain'].toString(),
        createdAt: json['created_at']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "activity_id": activityId,
        "source_lat": sourceLat,
        "userid": userId,
        "source_lng": sourceLng,
        "destination_lat": destinationLat,
        "destination_lng": destinationLng,
        "time_taken": timeTaken,
        "avg_pace": avgPace,
        "distance": distance,
        "over_speeding": overSpeeding == "true" ? 1 : 0,
        "calories_burned": caloriesBurned,
        "elevation_gain": elevationGain,
      };
}

class InsertActivityResponse {
  final String status;
  final int? insertLastId;
  final String message;

  InsertActivityResponse({
    required this.status,
    this.insertLastId,
    required this.message,
  });

  factory InsertActivityResponse.fromJson(Map<String, dynamic> json) {
     try {
    return InsertActivityResponse(
      status: json['status']?.toString() ?? 'error',
      insertLastId: json['insertLast_Id'] is int 
          ? json['insertLast_Id'] 
          : int.tryParse(json['insertLast_Id']?.toString() ?? '0'),
      message: json['message']?.toString() ?? 'Unknown error',
    );
  } catch (e) {
    log('Error parsing InsertActivityResponse: $e');
    return InsertActivityResponse(
      status: 'error',
      message: 'Error parsing response: ${e.toString()}',
    );
  }
  }
}