import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:orka_sports/core/services/secure_storage_service.dart';
import 'package:orka_sports/data/models/location/get_partner_loc_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  final String baseUrl = 'https://fitfirst.online/api';

  Future<Map<String, dynamic>> updateLocationAPI(double latitude, double longitude) async {
    try {
      final token = await SecureStorageService().readToken();
      final sharedPreferences = await SharedPreferences.getInstance();
      final userId = sharedPreferences.getString('userId');

      log('=== Location Update Debug Info ===');
      log('UserId from SharedPrefs: $userId');
      log('Token from SecureStorage: $token');
      log('Latitude: $latitude');
      log('Longitude: $longitude');

      if (userId == null || userId.isEmpty) {
        return {
          'success': false,
          'message': 'User ID not found in SharedPreferences',
          'data': null,
        };
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/userlocation'),
      );

      // Add headers
      if (token != null) {
        request.headers['Authorization'] = token;
      }

      // Add form fields
      request.fields['userid'] = userId;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      log('Request fields: ${request.fields}');
      log('Request headers: ${request.headers}');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('Location update response: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return {
            'success': true,
            'message': responseData['message'] ?? 'Location updated successfully',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Unknown error',
            'data': responseData,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to update location: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      log('Error updating location: $e');
      return {
        'success': false,
        'message': 'Error updating location: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, double>?> getUserLocation() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final userId = sharedPreferences.getString('userId');
      final token = await SecureStorageService().readToken();

      if (userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/showProfile?userid=$userId'),
        headers: token != null ? {'Authorization': token} : {},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];
        log("data : ${data.toString()}");
        if (data['latitude'] != null && data['longitude'] != null) {
          return {
            'latitude': double.parse(data['latitude'].toString()),
            'longitude': double.parse(data['longitude'].toString()),
          };
        }
      }
      return null;
    } catch (e) {
      log('Error fetching user location: $e');
      return null;
    }
  }

  // Fetch partner locations based on userId
  Future<GetPartnerLocModel?> getPartnerLocations() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = await SecureStorageService().readToken();
      final userId = sharedPreferences.getString('userId');

      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Create the form data to send in the POST request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/getpartners'), // Replace with actual API endpoint
      );

      // Add the form fields
      request.fields['userid'] = userId;

      // Add the authorization token (if exists)
      if (token != null) {
        request.headers['Authorization'] = token;
      }

      // Send the request and get the response
      final response = await request.send();

      // Process the response
      final responseBody = await response.stream.bytesToString();
      log('getPartnerLocations status: ${response.statusCode}');
      log('getPartnerLocations body: $responseBody');

      if (response.statusCode == 200) {
        // Parse the response and return the model
        return GetPartnerLocModel.fromJson(json.decode(responseBody));
      } else {
        throw Exception('Failed to load partner locations');
      }
    } catch (e) {
      log('Error in getPartnerLocations: $e');
    }
    return null;
  }
}
