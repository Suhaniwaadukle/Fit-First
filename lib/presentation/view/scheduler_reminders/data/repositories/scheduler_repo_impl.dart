import 'dart:developer';
import 'package:orka_sports/core/utils/error_handling.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/datasources/scheduler_service.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_progress_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_scheduler_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_today_workout_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/domain/repositories/scheduler_repo.dart';

class SchedulerRepoImpl extends SchedulerService implements SchedulerRepo {
  // Repo function for insert daily reminders/schedulers
  @override
  Future<dynamic> insertDailySchedule({required Map<String, dynamic> data}) async {
    try {
      final response = await saveDailyScheduleService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<dynamic> insertMealSchedule({required Map<String, dynamic> data}) async {
    try {
      final response = await saveMealScheduleService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<dynamic> insertSupplimentSchedule({required Map<String, dynamic> data}) async {
    try {
      final response = await saveSupplimentScheduleService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<dynamic> insertDailyReminder({required Map<String, dynamic> data}) async {
    try {
      final response = await saveDailyReminderService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  // Repo function for getting the full schedule by day
  @override
  Future<GetFullScheduleModel> getFullSchedule({required Map<String, dynamic> data}) async {
    try {
      final response = await getAllSchedule(data: data);
      GetFullScheduleModel getFullScheduleModel = GetFullScheduleModel.fromJson(response.data);
      return getFullScheduleModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  // Repo function to save weekly schedule
  @override
  Future<dynamic> saveWeeklyScheduleRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await saveWeeklyScheduleService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  // Repo function to get today workouts
  @override
  Future<GetTodayWorkOutModel> getTodaysWorkOutRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getTodayWorkoutsService(data: data);
      GetTodayWorkOutModel getTodayWorkOutModel = GetTodayWorkOutModel.fromJson(response.data);
      return getTodayWorkOutModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  // Repo function to get weekly progress
  @override
  Future<GetWeeklyProgressModel> getWeeklyProgressRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getWeeklyProgressService(data: data);
      GetWeeklyProgressModel getWeeklyProgressModel = GetWeeklyProgressModel.fromJson(response.data);
      return getWeeklyProgressModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }
}
