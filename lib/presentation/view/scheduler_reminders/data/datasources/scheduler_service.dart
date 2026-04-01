import 'package:dio/dio.dart';
import 'package:orka_sports/config/api_constants.dart';
import 'package:orka_sports/core/resources/api_interceptor.dart';

abstract class SchedulerService {
  final Dio dio = ApiInterceptor().dio;

  // Service fuction for daily scheduler & reminder
  Future<Response<dynamic>> saveDailyScheduleService({required Map<String, dynamic> data}) {
    final dailyReminder = dio.post(
      ApiConstants.saveDailySchedule,
      data: data,
    );
    return dailyReminder;
  }

  Future<Response<dynamic>> saveMealScheduleService({required Map<String, dynamic> data}) {
    final dailyReminder = dio.post(
      ApiConstants.saveMealSchedule,
      data: data,
    );
    return dailyReminder;
  }

  Future<Response<dynamic>> saveSupplimentScheduleService({required Map<String, dynamic> data}) {
    final dailyReminder = dio.post(
      ApiConstants.saveSuppliments,
      data: data,
    );
    return dailyReminder;
  }

  Future<Response<dynamic>> saveDailyReminderService({required Map<String, dynamic> data}) {
    final dailyReminder = dio.post(
      ApiConstants.saveReminders,
      data: data,
    );
    return dailyReminder;
  }

  // Service function to get all schedule by day
  Future<Response<dynamic>> getAllSchedule({required Map<String, dynamic> data}) {
    final fullSchedule = dio.post(
      ApiConstants.getFullScheduleByDay,
      data: data,
    );
    return fullSchedule;
  }

  //Service function to save weekly schedule
  Future<Response<dynamic>> saveWeeklyScheduleService({required Map<String, dynamic> data}) {
    final weekly = dio.post(
      ApiConstants.saveWeeklySchedule,
      data: data,
    );
    return weekly;
  }

  //Service function to get today workouts
  Future<Response<dynamic>> getTodayWorkoutsService({required Map<String, dynamic> data}) {
    final todayWorkout = dio.post(
      ApiConstants.getTodayWorkOutSchedule,
      data: data,
    );
    return todayWorkout;
  }

  //Service function to get weekly progress
  Future<Response<dynamic>> getWeeklyProgressService({required Map<String, dynamic> data}) {
    final weeklyProgress = dio.post(
      ApiConstants.getWeeklyProgress,
      data: data,
    );
    return weeklyProgress;
  }
}
