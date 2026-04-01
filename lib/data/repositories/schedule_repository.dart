import 'package:dio/dio.dart';
import 'package:orka_sports/data/models/schedule/full_schedule_model.dart';
import 'package:intl/intl.dart';

class ScheduleRepository {
  final Dio _dio;

  ScheduleRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<FullScheduleResponse> getFullScheduleByDay({
    required String userId,
    required String day,
  }) async {
    try {
      print('=== SCHEDULE REPOSITORY: getFullScheduleByDay ===');
      print('URL: https://fitfirst.online/Api/getFullScheduleByDay');
      print('Request Data: {user_id: $userId, day: $day}');
      
      final response = await _dio.post(
        'https://fitfirst.online/Api/getFullScheduleByDay',
        data: {
          'user_id': int.parse(userId),
          'day': day,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('=== SCHEDULE REPOSITORY RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        return FullScheduleResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch schedule: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('=== SCHEDULE REPOSITORY DIO ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception('API Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      print('=== SCHEDULE REPOSITORY GENERAL ERROR ===');
      print('Error: $e');
      throw Exception('Failed to fetch full schedule: $e');
    }
  }

  // ✅ Extract exercise schedule from full schedule response
  Future<Map<String, dynamic>> getExerciseScheduleByDay({
    required String userId,
    required String day,
  }) async {
    try {
      print('=== GETTING EXERCISE SCHEDULE BY DAY ===');
      print('URL: https://fitfirst.online/Api/getFullScheduleByDay');
      print('Request Data: {user_id: $userId, day: $day}');
      
      final response = await _dio.post(
        'https://fitfirst.online/Api/getFullScheduleByDay',
        data: {
          'user_id': int.parse(userId),
          'day': day,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('=== FULL SCHEDULE RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final fullScheduleData = response.data['data'];
        
        // ✅ Extract exercise data from daily_schedule
        if (fullScheduleData != null && fullScheduleData['daily_schedule'] != null) {
          final exerciseData = fullScheduleData['daily_schedule'];
          
          // Check if exercise data has required fields
          if (exerciseData['workout'] != null || 
              exerciseData['workout_time_from'] != null || 
              exerciseData['workout_time_to'] != null) {
            
            print('=== EXERCISE DATA FOUND ===');
            print('Exercise Data: $exerciseData');
            
            return {
              'success': true,
              'data': exerciseData
            };
          }
        }
        
        // ✅ No exercise data found
        print('=== NO EXERCISE DATA FOUND ===');
        return {'success': false, 'data': null};
        
      } else {
        print('=== API RESPONSE NOT SUCCESS ===');
        return {'success': false, 'data': null};
      }
    } on DioException catch (e) {
      print('=== EXERCISE SCHEDULE DIO ERROR ===');
      print('Error: ${e.message}');
      return {'success': false, 'data': null};
    } catch (e) {
      print('=== EXERCISE SCHEDULE GENERAL ERROR ===');
      print('Error: $e');
      return {'success': false, 'data': null};
    }
  }

  // ✅ Method to save exercise schedule (handles both add and update)
  Future<Map<String, dynamic>> saveExerciseSchedule({
    required String userId,
    required String day,
    required List<String> workouts,
    required String fromTime,
    required String toTime,
    String? scheduleId, // For updates
  }) async {
    try {
      final workoutsString = workouts.join(', ');
      
      print('=== SAVING EXERCISE SCHEDULE ===');
      print('URL: https://fitfirst.online/Api/saveDailySchedule');
      
      final data = {
        'user_id': int.parse(userId),
        'day': day,
        'workout': workoutsString,
        'workout_time_from': fromTime,
        'workout_time_to': toTime,
      };
      
      // Add schedule ID if updating
      if (scheduleId != null) {
        data['schedule_id'] = scheduleId;
      }
      
      print('Request Data: $data');
      
      final response = await _dio.post(
        'https://fitfirst.online/Api/saveDailySchedule',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('=== SAVE SCHEDULE RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to save schedule: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('=== SAVE SCHEDULE DIO ERROR ===');
      print('Error: ${e.message}');
      throw Exception('Network Error: ${e.message}');
    } catch (e) {
      print('=== SAVE SCHEDULE GENERAL ERROR ===');
      print('Error: $e');
      throw Exception('Failed to save schedule: $e');
    }
  }

  Future<Map<String, dynamic>> recordMealAction({
    required String userId,
    required String day,
    required String mealName,
    required String action,
  }) async {
    try {
      print('=== RECORDING MEAL ACTION ===');
      print('URL: https://fitfirst.online/Api/recordMealAction');
      print('Request Data: {user_id: $userId, day: $day, meal_name: $mealName, action: $action}');
      
      final response = await _dio.post(
        'https://fitfirst.online/Api/recordMealAction',
        data: {
          'user_id': int.parse(userId),
          'day': day,
          'meal_name': mealName,
          'action': action,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      print('=== MEAL ACTION RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to record meal action: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('=== MEAL ACTION DIO ERROR ===');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response: ${e.response?.data}');
      
      if (e.response != null) {
        throw Exception('API Error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      print('=== MEAL ACTION GENERAL ERROR ===');
      print('Error: $e');
      throw Exception('Failed to record meal action: $e');
    }
  }
}
