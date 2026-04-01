class ActivityListResponse {
  final String status;
  final List<ActivityListItem>? data;
  final String message;

  ActivityListResponse({
    required this.status,
    this.data,
    required this.message,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) {
    return ActivityListResponse(
      status: json['status'],
      data: json['data'] != null
          ? List<ActivityListItem>.from(
              json['data'].map((x) => ActivityListItem.fromJson(x)))
          : null,
      message: json['message'],
    );
  }
}

class ActivityListItem {
  final String id;
  final String name;
  final String createdAt;

  ActivityListItem({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory ActivityListItem.fromJson(Map<String, dynamic> json) {
    return ActivityListItem(
      id: json['id'].toString(),
      name: json['name'],
      createdAt: json['created_at'],
    );
  }
} 