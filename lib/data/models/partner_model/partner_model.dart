class PartnerModel {
  final String id;
  final String name;
  final String partnerImage;
  final String distance;
  final String phoneCode;
  final String mobile;

  PartnerModel({
    required this.id,
    required this.name,
    required this.partnerImage,
    required this.distance,
    required this.phoneCode,
    required this.mobile,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      partnerImage: json['partner_image'] ?? '',
      distance: json['distance']?.toString() ?? '0',
      phoneCode: json['phonecode']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
    );
  }
}

class PartnersResponse {
  final String status;
  final List<PartnerModel> data;
  final String message;

  PartnersResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory PartnersResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    return PartnersResponse(
      status: json['status'],
      // data: (json['data'] as List).map((e) => Partner.fromJson(e)).toList(),
      data: (dataList is List) ? dataList.map((e) => PartnerModel.fromJson(e)).toList() : [],
      message: json['message'] ?? '',
    );
  }
}
