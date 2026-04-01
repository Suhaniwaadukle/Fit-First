import 'dart:developer';

class UserData {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phonecode;
  final String? mobile;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phonecode,
    this.mobile,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    log('Parsing UserData: $json');
    return UserData(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profile_image']?? '',
      phonecode: json['phonecode'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'profile_image': profileImage,
    'phonecode': phonecode,
    'mobile': mobile,
  };
} 
