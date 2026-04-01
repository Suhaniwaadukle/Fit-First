// class ActivitySubCategoryResponse {
//   final String status;
//   final List<ActivitySubCategory>? data;
//   final String message;

//   ActivitySubCategoryResponse({
//     required this.status,
//     this.data,
//     required this.message,
//   });

//   factory ActivitySubCategoryResponse.fromJson(Map<String, dynamic> json) {
//     return ActivitySubCategoryResponse(
//       status: json['status'],
//       data: json['data'] != null
//           ? List<ActivitySubCategory>.from(json['data'].map((x) => ActivitySubCategory.fromJson(x)))
//           : null,
//       message: json['message'],
//     );
//   }
// }

// class ActivitySubCategory {
//   final String id;
//   final String activityID;
//   final List<SubCategory> activitySubCategory;
//   final String createdAt;

//   ActivitySubCategory({
//     required this.id,
//     required this.activityID,
//     required this.activitySubCategory,
//     required this.createdAt,
//   });

//   factory ActivitySubCategory.fromJson(Map<String, dynamic> json) {
//     return ActivitySubCategory(
//       id: json['id'],
//       activityID: json['activityID'],
//       activitySubCategory:
//           ((json['activity_sub_category'] ?? json['activity_nutrition_sub_category']) as List<dynamic>?)
//                   ?.map((x) => SubCategory.fromJson(jsonDecode(x as String)))
//                   .toList() ??
//               [],
//       createdAt: json['created_at'],
//     );
//   }
// }

// class SubCategory {
//   final String id;
//   final String name;
//   final String icon;
//   SubCategory({
//     required this.id,
//     required this.name,
//     required this.icon,
//   });

//   factory SubCategory.fromJson(Map<String, dynamic> json) {
//     return SubCategory(
//       id: json['id'],
//       name: json['name'],
//       icon: json['icon'].toString(),
//     );
//   }
// }

class ActivitySubCategoryResponse {
  final String status;
  final List<ActivitySubCategory>? data;
  final String message;

  ActivitySubCategoryResponse({
    required this.status,
    this.data,
    required this.message,
  });

  factory ActivitySubCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ActivitySubCategoryResponse(
      status: json['status'],
      data: json['data'] != null
          ? List<ActivitySubCategory>.from(json['data'].map((x) => ActivitySubCategory.fromJson(x)))
          : null,
      message: json['message'],
    );
  }
}

class ActivitySubCategory {
  final String id;
  final String activityID;
  final List<SubCategory> activitySubCategory;
  final String createdAt;

  ActivitySubCategory({
    required this.id,
    required this.activityID,
    required this.activitySubCategory,
    required this.createdAt,
  });

  factory ActivitySubCategory.fromJson(Map<String, dynamic> json) {
    return ActivitySubCategory(
      id: json['id'],
      activityID: json['activityID'],
      activitySubCategory: (json['activity_sub_category'] ?? json['activity_nutrition_sub_category'] ?? [])
          .map<SubCategory>((x) => SubCategory.fromJson(x))
          .toList(),
      createdAt: json['created_at'],
    );
  }
}

class SubCategory {
  final String id;
  final String name;
  final String icon;

  SubCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'].toString(),
    );
  }
}
