import 'package:flutter/material.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_progress_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_scheduler_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_today_workout_model.dart';

class SupplementScheduleEntity {
  final TextEditingController supplementNameController = TextEditingController();
  final TextEditingController timeSlotController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
}

@immutable
class SchedulerEntity {
  final bool isAllScheduleLoading;
  final GetFullScheduleModel getFullScheduleModel;
  final TextEditingController dayController;
  final TextEditingController workoutController;
  final TextEditingController workoutTimeController;
  final TextEditingController fromTimeController;
  final TextEditingController toTimeController;
  final Map<String, TextEditingController> gymWorkoutControllers;
  final Map<String, TextEditingController> gymFromTimeControllers;
  final Map<String, TextEditingController> gymToTimeControllers;
  final TextEditingController breakfastTimeController;
  final TextEditingController midMorningSnackTimeController;
  final TextEditingController lunchTimeController;
  final TextEditingController preWorkoutTimeController;
  final TextEditingController postWorkoutTimeController;
  final TextEditingController dinnerTimeController;
  final List<SupplementScheduleEntity> supplementControllers;
  final bool isDailyScheduleLoading;
  final TextEditingController reminderDayController;
  final TextEditingController reminderWaterController;
  final TextEditingController meditationController;
  final TextEditingController exerciseController;
  final TextEditingController supplimentTimeController;
  final bool isWaterToggle;
  final bool isMeditationToggle;
  final bool isExerciseToggle;
  final String selectedSupplementTime;
  final bool isReminderValidation;
  final bool isSaveWeeklyLoading;
  final bool isTodayWorkOutLoading;
  final bool isWeeklyProgressLoading;
  final GetTodayWorkOutModel getTodayWorkOutList;
  final GetWeeklyProgressModel getWeeklyProgressList;
  final bool isGymScheduleValid;
  final String greetingMessage;
  final Map<String, List<String>> selectedWorkoutsPerDay;

  const SchedulerEntity({
    required this.isAllScheduleLoading,
    required this.getFullScheduleModel,
    required this.dayController,
    required this.workoutController,
    required this.workoutTimeController,
    required this.fromTimeController,
    required this.toTimeController,

    // ✅ NEW
    required this.gymWorkoutControllers,
    required this.gymFromTimeControllers,
    required this.gymToTimeControllers,
    required this.breakfastTimeController,
    required this.midMorningSnackTimeController,
    required this.lunchTimeController,
    required this.preWorkoutTimeController,
    required this.postWorkoutTimeController,
    required this.dinnerTimeController,
    required this.supplementControllers,
    required this.isDailyScheduleLoading,
    required this.reminderDayController,
    required this.reminderWaterController,
    required this.meditationController,
    required this.exerciseController,
    required this.supplimentTimeController,
    required this.isWaterToggle,
    required this.isMeditationToggle,
    required this.isExerciseToggle,
    required this.selectedSupplementTime,
    required this.isReminderValidation,
    required this.isSaveWeeklyLoading,
    required this.isTodayWorkOutLoading,
    required this.isWeeklyProgressLoading,
    required this.getTodayWorkOutList,
    required this.getWeeklyProgressList,
    required this.isGymScheduleValid,
    required this.greetingMessage,
    required this.selectedWorkoutsPerDay,
  });

  factory SchedulerEntity.initial() {
    final List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final gymWorkoutControllers = {
      for (var day in days) day: TextEditingController(),
    };
    final gymFromTimeControllers = {
      for (var day in days) day: TextEditingController(),
    };
    final gymToTimeControllers = {
      for (var day in days) day: TextEditingController(),
    };
    final selectedWorkoutsPerDay = {
      for (var day in days) day: <String>[],
    };

    return SchedulerEntity(
        isAllScheduleLoading: false,
        getFullScheduleModel: GetFullScheduleModel(),

        // Existing
        dayController: TextEditingController(text: "Select day"),
        workoutController: TextEditingController(),
        workoutTimeController: TextEditingController(),
        fromTimeController: TextEditingController(),
        toTimeController: TextEditingController(),

        // ✅ NEW
        gymWorkoutControllers: gymWorkoutControllers,
        gymFromTimeControllers: gymFromTimeControllers,
        gymToTimeControllers: gymToTimeControllers,

        // Meal
        breakfastTimeController: TextEditingController(),
        midMorningSnackTimeController: TextEditingController(),
        lunchTimeController: TextEditingController(),
        preWorkoutTimeController: TextEditingController(),
        postWorkoutTimeController: TextEditingController(),
        dinnerTimeController: TextEditingController(),

        // Supplement
        supplementControllers: [SupplementScheduleEntity()],
        isDailyScheduleLoading: false,
        reminderDayController: TextEditingController(text: "Select day"),
        reminderWaterController: TextEditingController(),
        meditationController: TextEditingController(),
        exerciseController: TextEditingController(),
        supplimentTimeController: TextEditingController(),
        isWaterToggle: false,
        isMeditationToggle: false,
        isExerciseToggle: false,
        selectedSupplementTime: 'Morning',
        isReminderValidation: false,
        isSaveWeeklyLoading: false,
        isTodayWorkOutLoading: false,
        isWeeklyProgressLoading: false,
        getTodayWorkOutList: GetTodayWorkOutModel(),
        getWeeklyProgressList: GetWeeklyProgressModel(),
        isGymScheduleValid: false,
        greetingMessage: "",
        selectedWorkoutsPerDay: selectedWorkoutsPerDay);
  }

  SchedulerEntity copyWith({
    bool? isAllScheduleLoading,
    GetFullScheduleModel? getFullScheduleModel,
    TextEditingController? dayController,
    TextEditingController? workoutController,
    TextEditingController? workoutTimeController,
    TextEditingController? fromTimeController,
    TextEditingController? toTimeController,
    Map<String, TextEditingController>? gymWorkoutControllers,
    Map<String, TextEditingController>? gymFromTimeControllers,
    Map<String, TextEditingController>? gymToTimeControllers,
    TextEditingController? breakfastTimeController,
    TextEditingController? midMorningSnackTimeController,
    TextEditingController? lunchTimeController,
    TextEditingController? preWorkoutTimeController,
    TextEditingController? postWorkoutTimeController,
    TextEditingController? dinnerTimeController,
    List<SupplementScheduleEntity>? supplementControllers,
    bool? isDailyScheduleLoading,
    TextEditingController? reminderDayController,
    TextEditingController? reminderWaterController,
    TextEditingController? meditationController,
    TextEditingController? exerciseController,
    TextEditingController? supplimentTimeController,
    bool? isWaterToggle,
    bool? isMeditationToggle,
    bool? isExerciseToggle,
    String? selectedSupplementTime,
    bool? isReminderValidation,
    bool? isSaveWeeklyLoading,
    bool? isTodayWorkOutLoading,
    bool? isWeeklyProgressLoading,
    GetTodayWorkOutModel? getTodayWorkOutList,
    GetWeeklyProgressModel? getWeeklyProgressList,
    bool? isGymScheduleValid,
    String? greetingMessage,
    Map<String, List<String>>? selectedWorkoutsPerDay,
  }) {
    return SchedulerEntity(
      isAllScheduleLoading: isAllScheduleLoading ?? this.isAllScheduleLoading,
      getFullScheduleModel: getFullScheduleModel ?? this.getFullScheduleModel,

      dayController: dayController ?? this.dayController,
      workoutController: workoutController ?? this.workoutController,
      workoutTimeController: workoutTimeController ?? this.workoutTimeController,
      fromTimeController: fromTimeController ?? this.fromTimeController,
      toTimeController: toTimeController ?? this.toTimeController,

      // ✅ NEW
      gymWorkoutControllers: gymWorkoutControllers ?? this.gymWorkoutControllers,
      gymFromTimeControllers: gymFromTimeControllers ?? this.gymFromTimeControllers,
      gymToTimeControllers: gymToTimeControllers ?? this.gymToTimeControllers,

      breakfastTimeController: breakfastTimeController ?? this.breakfastTimeController,
      midMorningSnackTimeController: midMorningSnackTimeController ?? this.midMorningSnackTimeController,
      lunchTimeController: lunchTimeController ?? this.lunchTimeController,
      preWorkoutTimeController: preWorkoutTimeController ?? this.preWorkoutTimeController,
      postWorkoutTimeController: postWorkoutTimeController ?? this.postWorkoutTimeController,
      dinnerTimeController: dinnerTimeController ?? this.dinnerTimeController,
      supplementControllers: supplementControllers ?? this.supplementControllers,
      isDailyScheduleLoading: isDailyScheduleLoading ?? this.isDailyScheduleLoading,
      reminderDayController: reminderDayController ?? this.reminderDayController,
      reminderWaterController: reminderWaterController ?? this.reminderWaterController,
      meditationController: meditationController ?? this.meditationController,
      exerciseController: exerciseController ?? this.exerciseController,
      supplimentTimeController: supplimentTimeController ?? this.supplimentTimeController,
      isWaterToggle: isWaterToggle ?? this.isWaterToggle,
      isMeditationToggle: isMeditationToggle ?? this.isMeditationToggle,
      isExerciseToggle: isExerciseToggle ?? this.isExerciseToggle,
      selectedSupplementTime: selectedSupplementTime ?? this.selectedSupplementTime,
      isReminderValidation: isReminderValidation ?? this.isReminderValidation,
      isSaveWeeklyLoading: isSaveWeeklyLoading ?? this.isSaveWeeklyLoading,
      isTodayWorkOutLoading: isTodayWorkOutLoading ?? this.isTodayWorkOutLoading,
      isWeeklyProgressLoading: isWeeklyProgressLoading ?? this.isWeeklyProgressLoading,
      getTodayWorkOutList: getTodayWorkOutList ?? this.getTodayWorkOutList,
      getWeeklyProgressList: getWeeklyProgressList ?? this.getWeeklyProgressList,
      isGymScheduleValid: isGymScheduleValid ?? this.isGymScheduleValid,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      selectedWorkoutsPerDay: selectedWorkoutsPerDay ?? this.selectedWorkoutsPerDay,
    );
  }
}