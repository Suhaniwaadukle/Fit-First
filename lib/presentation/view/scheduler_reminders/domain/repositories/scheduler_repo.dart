import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_progress_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_scheduler_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_today_workout_model.dart';

abstract class SchedulerRepo {
  // Inset Daily Reminder/Scheduler
  Future<dynamic> insertDailySchedule({required Map<String, dynamic> data});
  Future<dynamic> insertMealSchedule({required Map<String, dynamic> data});
  Future<dynamic> insertSupplimentSchedule({required Map<String, dynamic> data});
  Future<dynamic> insertDailyReminder({required Map<String, dynamic> data});
  // Get Function For All Scheduler/Reminders
  Future<GetFullScheduleModel> getFullSchedule({required Map<String, dynamic> data});
  // Repo function to save weekly schedule, get today workout& weekly progress
  Future<dynamic> saveWeeklyScheduleRepo({required Map<String, dynamic> data});
  Future<GetTodayWorkOutModel> getTodaysWorkOutRepo({required Map<String, dynamic> data});
  Future<GetWeeklyProgressModel> getWeeklyProgressRepo({required Map<String, dynamic> data});
}
