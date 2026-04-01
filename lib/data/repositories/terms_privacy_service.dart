import 'dart:convert';

import 'package:orka_sports/data/models/terms_privacy/terms_privacy_model.dart';
import 'package:http/http.dart' as http;

class TermsPrivacyService {
  static const String baseUrl = 'https://fitfirst.online/api';

  static Future<ApiResponse> fetchTermsAndPrivacy() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/term_n_policies'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}