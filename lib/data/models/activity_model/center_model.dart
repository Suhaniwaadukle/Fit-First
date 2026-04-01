class YogaZumbaCenter {
  final String partnerID;
  final String partnerName;
  final String partnerLat;
  final String partnerLong;
  final String partnerImage;
  final String distance;
  final String partnerProfile;

  YogaZumbaCenter({
    required this.partnerID,
    required this.partnerName,
    required this.partnerLat,
    required this.partnerLong,
    required this.partnerImage,
    required this.distance,
    required this.partnerProfile,
  });

  factory YogaZumbaCenter.fromJson(Map<String, dynamic> json) {
    return YogaZumbaCenter(
      partnerID: json['partnerID'] ?? '',
      partnerName: json['partnerName'] ?? '',
      partnerLat: json['partnerLat'] ?? '',
      partnerLong: json['partnerLong'] ?? '',
      partnerImage: json['partner_image'] ?? '',
      distance: json['distance'] ?? '',
      partnerProfile: json['partnerProfile'] ?? '',
    );
  }
}
