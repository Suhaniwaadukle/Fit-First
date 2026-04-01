import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orka_sports/data/models/activity_model/center_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YogaZumbaCenterService {
  static const String baseUrl = 'https://fitfirst.online/Api';

  static Future<List<YogaZumbaCenter>> fetchCenters(String subIndustry) async {
    try {
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("userId");
      
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/getYogaZumbaCentersForUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': int.parse(userId),
          'sub_industry': subIndustry, // "yoga" or "zumba"
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == 'success') {
          List<dynamic> centersJson = jsonResponse['data'] ?? [];
          return centersJson.map((json) => YogaZumbaCenter.fromJson(json)).toList();
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load centers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching centers: $e');
    }
  }
}
