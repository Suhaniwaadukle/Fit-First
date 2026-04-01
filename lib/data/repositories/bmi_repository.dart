import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orka_sports/data/models/bmi_data/bmi_calculation.dart';
import 'package:orka_sports/data/models/bmi_data/bmi_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BmiRepository {
  static const String _bmiDataKey = 'bmi_data';
  final String _baseUrl = 'https://fitfirst.online/api';

  Future<void> saveBmiData(BmiData bmiData) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(bmiData.toJson());
    await prefs.setString(_bmiDataKey, jsonString);
  }

  Future<BmiData?> loadBmiData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bmiDataKey);

    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      return BmiData.fromJson(jsonMap);
    }

    return null;
  }

  Future<void> clearBmiData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bmiDataKey);
  }

  Future<bool> hasBmiData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_bmiDataKey);
  }

  Future<BmiApiResponseModel> calculateBmiFromApi({
    required double height,
    required int weight,
    required int age,
    required String gender,
    required String lifestyle, // Added lifestyle parameter
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    // Debug logging
    print("Height: $height");
    print("Weight: $weight");
    print("Age: $age");
    print("Gender: $gender");
    print("Lifestyle: $lifestyle"); // Added lifestyle logging
    print("User ID: $userId");

    // User ID validation
    if (userId == null || userId.isEmpty) {
      throw Exception("User ID is missing from SharedPreferences");
    }

    // Input validation
    if (height <= 0 || weight <= 0 || age <= 0) {
      throw Exception("Invalid input values");
    }
    if (gender.isEmpty) {
      throw Exception("Gender must not be empty");
    }
    if (lifestyle.isEmpty) {
      throw Exception("Lifestyle must not be empty"); // Added lifestyle validation
    }

    final uri = Uri.parse('$_baseUrl/getCalculateBMI');
    var request = http.MultipartRequest('POST', uri);
    request.fields['height'] = height.toString();
    request.fields['weight'] = weight.toString();
    request.fields['age'] = age.toString();
    request.fields['gender'] = gender;
    request.fields['lifestyle'] = lifestyle; // Added lifestyle field
    request.fields['user_id'] = userId;

    // Debug the request fields
    print("Request fields: ${request.fields}");

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          return BmiApiResponseModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to calculate BMI');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }
}
