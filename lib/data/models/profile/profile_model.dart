import 'dart:developer';

class ProfileResponse {
  final bool success;
  final String message;
  final ProfileData? data;

  ProfileResponse({required this.success, required this.message, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }
}

class ProfileData {
  String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phonecode;
  final String? mobile;
  final String? gender;
  final String? height;
  final String? weight;
  final String? dob;
  final String? latitude;
  final String? longitude;
  final String? walkId;
  final String? runningId;
  final String? cyclingId;
  final String? age;

  ProfileData({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phonecode,
    this.mobile,
    this.gender,
    this.height,
    this.weight,
    this.dob,
    this.latitude,
    this.longitude,
    this.walkId,
    this.runningId,
    this.cyclingId,
    this.age,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    log('From ${json['mobile']}sss');
    return ProfileData(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_photo'] ?? '',
      phonecode: json['phonecode']?.toString() ?? '+91',
      mobile: json['mobile']?.toString() ?? 'NO Number',
      gender: json['gender'] ?? '',
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      dob: json['date_of_birth'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      walkId: json['walkId'] ?? '',
      runningId: json['RunningId'] ?? '',
      cyclingId: json['CyclingId'] ?? '',
      age: json['age'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': id,
      'name': name,
      'email': email,
      'country_code': phonecode ?? '+91',
      'mobile_number': mobile ?? '',
      'gender': gender ?? '',
      'height': height ?? '',
      'weight': weight ?? '',
      'dob': dob ?? '',
      'profile_photo': profileImage ?? '',
      'latitude': latitude ?? '',
      'longitude': longitude ?? '',
      'walkId': walkId ?? '',
      'RunningId': runningId ?? '',
      'CyclingId': cyclingId ?? '',
      'age': age ?? '',
    };
  }

  ProfileData copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? phonecode,
    String? mobile,
    String? gender,
    String? height,
    String? weight,
    String? dob,
    String? age,
  }) {
    return ProfileData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phonecode: phonecode ?? this.phonecode,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dob: dob ?? this.dob,
      age: age ?? this.age,
    );
  }
}
