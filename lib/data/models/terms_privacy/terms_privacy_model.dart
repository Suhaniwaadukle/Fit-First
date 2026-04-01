class TermsPrivacyData {
  final String id;
  final String type;
  final String content;
  final String createdAt;
  final String updatedAt;

  TermsPrivacyData({
    required this.id,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TermsPrivacyData.fromJson(Map<String, dynamic> json) {
    return TermsPrivacyData(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ApiResponse {
  final String status;
  final List<TermsPrivacyData> data;
  final String message;

  ApiResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<TermsPrivacyData> data = dataList.map((i) => TermsPrivacyData.fromJson(i)).toList();

    return ApiResponse(
      status: json['status'],
      data: data,
      message: json['message'],
    );
  }
}
