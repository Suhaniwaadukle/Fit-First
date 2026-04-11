import 'dart:convert';
import 'dart:developer';

import 'package:orka_sports/core/services/secure_storage_service.dart';
import 'package:orka_sports/data/models/activity_model/activity_list_model.dart';
import 'package:orka_sports/data/models/activity_model/activity_model.dart';
import 'package:http/http.dart' as http;
import 'package:orka_sports/data/models/activity_model/activity_subcategory_model.dart';
import 'package:orka_sports/data/models/bmi_data/bmi_daily_exercise_model.dart';
import 'package:orka_sports/data/models/bmi_data/bmi_exercise_model.dart';
import 'package:orka_sports/data/models/partner_model/partner_model.dart';
import 'package:orka_sports/data/models/product_details_model/product_details_model.dart';
import 'package:orka_sports/data/models/product_details_model/weight_variant_model.dart';
import 'package:orka_sports/data/models/product_model/prodcut_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityRepository {
  final String _baseUrl = 'https://fitfirst.online/Api';

  Future<Map<String, String>> _getHeaders({
    bool isMultipart = false,
    bool isFormUrlEncoded = false,
  }) async {
    final token = await SecureStorageService().readToken();
    return {
      if (!isMultipart && !isFormUrlEncoded) 'Content-Type': 'application/json',
      if (isFormUrlEncoded) 'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      if (token != null) 'Authorization': token,
    };
  }

  Future<InsertActivityResponse> insertActivityMultipart(
    ActivityData activityData,
  ) async {
    try {
      final headers = await _getHeaders(isMultipart: true);
      var uri = Uri.parse('$_baseUrl/insertActivity');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.fields['userid'] = activityData.userId;
      request.fields['activity_id'] = activityData.activityId!;
      request.fields['activity_name'] = _getActivityName(
        activityData.activityName ?? '',
      );
      request.fields['source_lat'] = activityData.sourceLat;
      request.fields['source_lng'] = activityData.sourceLng;
      request.fields['destination_lat'] = activityData.destinationLat;
      request.fields['destination_lng'] = activityData.destinationLng;
      request.fields['time_taken'] = '"${activityData.timeTaken}"';
      request.fields['avg_pace'] = activityData.avgPace;
      request.fields['distance'] = activityData.distance;
      request.fields['over_speeding'] = activityData.overSpeeding;
      request.fields['calories_burned'] = activityData.caloriesBurned;
      request.fields['elevation_gain'] = activityData.elevationGain;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData is! Map<String, dynamic>) {
          log('Error: Response data is not a Map: $responseData');
          return InsertActivityResponse(
            status: 'error',
            message: 'Invalid response format from server',
          );
        }
        return InsertActivityResponse.fromJson(responseData);
      } else {
        return InsertActivityResponse(
          status: 'error',
          message: 'Failed to insert activity. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error inserting activity: $e');
      return InsertActivityResponse(
        status: 'error',
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<GetActivityResponse> getActivities(String userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/getActivity?userid=$userId'),
        headers: headers,
      );

      log('Get Activities Response Status: ${response.statusCode}');
      log('Get Activities Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return GetActivityResponse.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        return GetActivityResponse(
          status: 'error',
          message: errorData['message'] ?? 'Failed to get activities. Status: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      log('Error getting activities: $e');
      return GetActivityResponse(
        status: 'error',
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  //! Get the actvitiy for nutrition and gear based on the activity type
  Future<ActivityListResponse> getActivitiesList() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_activities'));

      log('Get Activities List Response Status: ${response.statusCode}');
      log('Get Activities List Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ActivityListResponse.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        return ActivityListResponse(
          status: 'error',
          message: errorData['message'] ?? 'Failed to get activities list',
          data: null,
        );
      }
    } catch (e) {
      log('Error getting activities list: $e');
      return ActivityListResponse(
        status: 'error',
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  //! Get activity_subcategory
  Future<ActivitySubCategoryResponse> getSubCategoriesForActivity(
    String activityId,
    String activityType,
  ) async {
    try {
      final headers = await _getHeaders(isFormUrlEncoded: true);

      final body = {'activityID': activityId, 'activity_type': activityType};
       log('🔍 Sending activityID: $activityId');
    log('🔍 Sending activity_type: $activityType');

      log('Request Body (Form Data): $body');

      final response = await http.post(
        Uri.parse('$_baseUrl/getSubCategoriesForActivity'),
        headers: headers,
        body: body,
      );

      log('Get SubCategories Response Status: ${response.statusCode}');
      log('Get SubCategories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return ActivitySubCategoryResponse.fromJson(responseData);
      } else {
        final errorData = json.decode(response.body);
        return ActivitySubCategoryResponse(
          status: 'error',
          message: errorData['message'] ?? 'Failed to get subcategories',
          data: null,
        );
      }
    } catch (e) {
      log('Error getting subcategories: $e');
      return ActivitySubCategoryResponse(
        status: 'error',
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

Future<PartnersResponse> getPartnersForSubCategory({
  required String userId,
  required String subcategoryId,
}) async {
  try {
    final uri = Uri.parse('$_baseUrl/getPartnersForSubCategory');
    var request = http.MultipartRequest('POST', uri);
    request.fields['userID'] = userId;
    request.fields['subcategoryID'] = subcategoryId;
    print("🔍 === API REQUEST DEBUG ===");
    print("🔍 Working Example - userID: '1549', subcategoryID: '59'");
    print("🔍 Your App Sending - userID: '$userId', subcategoryID: '$subcategoryId'");
    print("🔍 Fields match working example: ${userId == '1549' && subcategoryId == '59'}");
    print("🔍 Request fields: ${request.fields}");
    print("🔍 === END DEBUG ===");

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    log('Get Partners Response Status: ${response.statusCode}');
    log('Get Partners Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PartnersResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch partners: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching partners: $e');
  }
}

  Future<ProductResponse> getProductsByPartner({
    required String partnerId,
    required String subcategoryId,
  }) async
  {
    try {
      final uri = Uri.parse('$_baseUrl/getProductByPartner');
      var request = http.MultipartRequest('POST', uri);
      request.fields['partner_id'] = partnerId;
      request.fields['subcategoryID'] = subcategoryId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Get Products By Partner Response Status: ${response.statusCode}');
      log('Get Products By Partner Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is! Map<String, dynamic>) {
          throw Exception('Invalid response format from server');
        }
        return ProductResponse.fromJson(jsonData);
      } else {
        try {
          final errorJson = jsonDecode(response.body);
          throw Exception(
              'Failed to fetch products: ${errorJson['message'] ?? 'Unknown error'} (Status: ${response.statusCode})');
        } catch (e) {
          throw Exception('Failed to fetch products. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      log('Error fetching products: $e');
      throw Exception('Error fetching products: ${e.toString()}');
    }
  }

  //! Product Details
  Future<List<ProductDetailsModel>> getProductDetails({
    required String partnerId,
    required String subCategoryId,
    required String productName,
  }) async
  {
    try {
      // Use http.post instead of http.get
      final uri = Uri.parse('$_baseUrl/getProductDetails');
      var request = http.MultipartRequest('POST', uri);
      request.fields['partner_id'] = partnerId;
      request.fields['subcategoryID'] = subCategoryId;
      request.fields['product_name'] = productName;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Status Code ${response.statusCode}');
      log('Product Details Body ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => ProductDetailsModel.fromJson(json)).toList();
        } else {
          final errorMessage = jsonResponse['message'] ?? 'Failed to load products';
          throw Exception(errorMessage);
        }
      } else {
        try {
          final errorJson = json.decode(response.body);
          final errorMessage = errorJson['message'] ?? 'Unknown error';
          throw Exception('Failed to load products: $errorMessage (Status: ${response.statusCode})');
        } catch (e) {
          throw Exception('Failed to load products. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching product details: ${e.toString()}');
    }
  }

  Future<List<WeightVariantModel>> getVariantsByWeight({
    required String partnerId,
    required String subCategoryId,
    required String productName,
    required String productWeight,
  }) async
  {
    try {
      final uri = Uri.parse('$_baseUrl/getProductDetailsForVarient');
      var request = http.MultipartRequest('POST', uri);
      request.fields['partner_id'] = partnerId;
      request.fields['subcategoryID'] = subCategoryId;
      request.fields['product_name'] = productName;
      request.fields['product_weight'] = productWeight;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Status Code ${response.statusCode}');
      log('Variants by Weight Body ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => WeightVariantModel.fromJson(json)).toList();
        } else {
          final errorMessage = jsonResponse['message'] ?? 'Failed to load variants';
          throw Exception(errorMessage);
        }
      } else {
        try {
          final errorJson = json.decode(response.body);
          final errorMessage = errorJson['message'] ?? 'Unknown error';
          throw Exception('Failed to load variants: $errorMessage (Status: ${response.statusCode})');
        } catch (e) {
          throw Exception('Failed to load variants. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error fetching product variants: ${e.toString()}');
    }
  }

  // Fetch Walk Recommendation
  Future<WalkRecommendationModel> getWalkRecommendation() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('$_baseUrl/getWalkRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bmi_category': prefs.getString("bmiCategory").toString(),
      }),
    );

    log('Walk Rec Status: ${response.statusCode}');
    log('Walk Rec Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return WalkRecommendationModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load walk recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // Fetch Run Recommendation
  Future<RunRecommendationModel> getRunRecommendation() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('$_baseUrl/getRunRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bmi_category': prefs.getString("bmiCategory").toString(),
      }),
    );

    log('Run Rec Status: ${response.statusCode}');
    log('Run Rec Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return RunRecommendationModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load run recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // Fetch Cycling Recommendation
  Future<CyclingRecommendationModel> getCyclingRecommendation() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('$_baseUrl/getCyclingRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bmi_category': prefs.getString("bmiCategory").toString(),
      }),
    );

    log('Cycling Rec Status: ${response.statusCode}');
    log('Cycling Rec Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return CyclingRecommendationModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load cycling recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // Fetch Hiking Recommendation
  Future<HikingRecommendationModel> getHikingRecommendation() async
  {
    final prefs = await SharedPreferences.getInstance();

    print("🔍 API URL: $_baseUrl/getHikingRecommendationByBMI");
    print("🔍 BMI Category sending: ${prefs.getString("bmiCategory")}");

    final uri = Uri.parse('$_baseUrl/getHikingRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bmi_category': prefs.getString("bmiCategory").toString(),
      }),
    );

    print("🔍 Status Code: ${response.statusCode}");
    print("🔍 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return HikingRecommendationModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load Hiking recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<DailyHikingRecommendationModel> getDailyHikingRecommendation({required double actualDistance}) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('$_baseUrl/getDailyHikingRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': prefs.getString('userId'),
        'bmi_category': prefs.getString('bmiCategory'),
        'actual_Hiking_km': actualDistance,
      }),
    );

    log('Daily Hiking Rec Status: ${response.statusCode}');
    log('Daily Hiking Rec Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return DailyHikingRecommendationModel.fromJson(jsonResponse);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load Hiking recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<DailyWalkRecommendationModel> getDailyWalkRecommendation({required double actualDistance}) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('$_baseUrl/getDailyWalkRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': prefs.getString('userId'), // make sure userId is stored
        'bmi_category': prefs.getString('bmiCategory'),
        'actual_walk_km': actualDistance,
      }),
    );

    log('Daily Walk Rec Status: ${response.statusCode}');
    log('Daily Walk Rec Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return DailyWalkRecommendationModel.fromJson(jsonResponse);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load walk recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<DailyRunRecommendationModel> getDailyRunRecommendation({required double actualDistance}) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('$_baseUrl/getDailyRunRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': prefs.getString('userId'),
        'bmi_category': prefs.getString('bmiCategory'),
        'actual_run_km': actualDistance,
      }),
    );

    log('Daily Run Rec Status: ${response.statusCode}');
    log('Daily Run Rec Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return DailyRunRecommendationModel.fromJson(jsonResponse);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load run recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<DailyCyclingRecommendationModel> getDailyCyclingRecommendation({required double actualDistance}) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse('$_baseUrl/getDailyCyclingRecommendationByBMI');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': prefs.getString('userId'),
        'bmi_category': prefs.getString('bmiCategory'),
        'actual_cycling_km': actualDistance,
      }),
    );

    log('Daily Cycling Rec Status: ${response.statusCode}');
    log('Daily Cycling Rec Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return DailyCyclingRecommendationModel.fromJson(jsonResponse);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load cycling recommendation');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

Future<Map<String, dynamic>> placeOrder({
  required String userId,
  required String itemId,
  required String partnersId,
  required String productSubCategory,
  required String productName,
  required String productDescription,
  required String productRealPrice,
  required String productDiscountPrice,
  required String productImage,
  required String productWeight,
  required String productVariant,
  required String partnersMobile,
  required String productDiscountPercentage,
  required String status,
}) async
{
  try {
    final uri = Uri.parse('$_baseUrl/placeOrder');
    var request = http.MultipartRequest('POST', uri);

    // Add all the required form-data fields
    request.fields['userid'] = userId;
    request.fields['Item_id'] = itemId;
    request.fields['partners_id'] = partnersId;
    request.fields['product_sub_category'] = productSubCategory;
    request.fields['product_name'] = productName;
    request.fields['product_description'] = productDescription;
    request.fields['product_real_price'] = productRealPrice;
    request.fields['product_discount_price'] = productDiscountPrice;
    request.fields['product_image'] = productImage;
    request.fields['product_weight'] = productWeight;
    request.fields['product_variant'] = productVariant;
    request.fields['partners_mobile'] = partnersMobile;
    request.fields['product_discount_percentage'] = productDiscountPercentage;
    request.fields['status'] = status;

    log('Place Order Request Fields: ${request.fields}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    log('Place Order Response Status: ${response.statusCode}');
    log('Place Order Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to place order: ${response.statusCode}');
    }
  } catch (e) {
    log('Error placing order: $e');
    throw Exception('Error placing order: $e');
  }
}

}

String _getActivityName(String activityType) {
  switch (activityType.toLowerCase()) {
    case 'walking':
      return 'walk';
    case 'running':
      return 'running';
    case 'cycling':
      return 'cycling';
      case 'hiking':
      return 'hiking';
    default:
      return activityType;
  }
}
