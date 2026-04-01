import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:orka_sports/data/models/goal_data/goal_data.dart';
// Assuming SecureStorageService and models are in these paths, adjust if necessary
// import 'package:orka_sports/core/services/secure_storage_service.dart'; // If auth is needed

class GoalRepository {
  final String _baseUrl = 'https://fitfirst.online/api';

  // Headers can be added here if common auth or content types are needed.
  // For 'noauth' APIs, specific headers per request might be simpler.

  /// Manages a goal (Create or Update) via POST request with form-data.
  Future<ManageGoalResponse> manageGoal(GoalData goalData) async {
    try {
      final uri = Uri.parse('$_baseUrl/manageGoals');
      var request = http.MultipartRequest('POST', uri);

      // Add fields from GoalData using the helper method
      request.fields.addAll(goalData.toApiRequestFields());

      // If Authorization or other specific headers are needed:
      // final token = await SecureStorageService().readToken();
      // if (token != null) {
      //   request.headers['Authorization'] = token;
      // }
      request.headers['Accept'] = 'application/json';


      log('Managing Goal - Request fields: ${request.fields}');
      log('Managing Goal - Request URL: ${request.url}');
      log('Managing Goal - Request Headers: ${request.headers}');


      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Manage Goal Response Status: ${response.statusCode}');
      log('Manage Goal Response Body: ${response.body}');

      final responseData = json.decode(response.body);
      log('$responseData');
      log('llllllllllll${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData is! Map<String, dynamic>) {
          log('Error: ManageGoalResponse data is not a Map: $responseData');
          return ManageGoalResponse(
            status: 'error',
            message: 'Invalid response format from server.',
          );
        }
        return ManageGoalResponse.fromJson(responseData);
      } else {
        return ManageGoalResponse(
          status: responseData['status']?.toString() ?? 'error',
          message: responseData['message']?.toString() ?? 'Failed to manage goal. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error managing goal: $e');
      return ManageGoalResponse(
        status: 'error',
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetches goals for a given userId via GET request.
  Future<GetGoalsResponse> getGoals(String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/getmanageGoals?userId=$userId');
      log('Fetching goals for userId: $userId from $uri');

      final Map<String, String> headers = {'Accept': 'application/json'};
      // final token = await SecureStorageService().readToken();
      // if (token != null) {
      //   headers['Authorization'] = token;
      // }
      
      final response = await http.get(uri, headers: headers);

      log('Get Goals Response Status: ${response.statusCode}');
      log('Get Goals Response Body: ${response.body}');
      
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return GetGoalsResponse.fromJson(responseData);
      } else {
         return GetGoalsResponse(
          status: responseData['status']?.toString() ?? 'error',
          message: responseData['message']?.toString() ?? 'Failed to get goals. Status: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      log('Error getting goals: $e');
      return GetGoalsResponse(
        status: 'error',
        message: 'An error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}