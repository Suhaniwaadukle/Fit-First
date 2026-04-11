// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/app/widgets/common_dialogs/common_dialogs.dart';
import 'package:orka_sports/app/widgets/common_formatter/common_formatter.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/view/main_screen/main_screen.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/models/get_scheduler_model.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/data/repositories/scheduler_repo_impl.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/domain/entities/scheduler_entity.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/domain/repositories/scheduler_repo.dart';
import 'package:orka_sports/presentation/widgets/common_time_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulerController extends StateNotifier<SchedulerEntity> {
  SchedulerController() : super(SchedulerEntity.initial());

  final SchedulerRepo _schedulerRepo = SchedulerRepoImpl();
  final CommonFormatter formatter = CommonFormatter();
  final SharedPreferences prefs = GetItService.getIt<SharedPreferences>();
  Timer? _greetingTimer;

  // Daily Scheduler & Reminders
  // Api Funcition for inserting the daily scheduler
  Future<void> insertAllDailySchedule(
    BuildContext context, {
    required String scheduleType,
  }) async {
    try {
      state = state.copyWith(isDailyScheduleLoading: true);
      Future<dynamic> insertCall;
      if (scheduleType == "Daily Schedule") {
        insertCall = _schedulerRepo.insertDailySchedule(data: {
          "user_id": prefs.getString("userId"),
          "day": formatter.checkValue(state.dayController.text),
          "workout": formatter.checkValue(state.workoutController.text),
          "workout_time_from": formatter.checkValue(state.fromTimeController.text),
          "workout_time_to": formatter.checkValue(state.toTimeController.text),
        });
      } else if (scheduleType == "Meal Schedule") {
        insertCall = _schedulerRepo.insertMealSchedule(data: {
          "user_id": prefs.getString("userId"),
          "day": formatter.checkValue(state.dayController.text),
          "breakfast": formatter.checkValue(state.breakfastTimeController.text),
          "mid_morning_snack": formatter.checkValue(state.midMorningSnackTimeController.text),
          "lunch": formatter.checkValue(state.lunchTimeController.text),
          "pre_workout": formatter.checkValue(state.preWorkoutTimeController.text),
          "post_workout": formatter.checkValue(state.postWorkoutTimeController.text),
          "dinner": formatter.checkValue(state.dinnerTimeController.text),
          "bedtime_protein": "8:00 PM",
        });
      } else if (scheduleType == "Daily Reminder") {
        insertCall = _schedulerRepo.insertDailyReminder(data: {
          "user_id": prefs.getString("userId"),
          "day": formatter.checkValue(state.reminderDayController.text),
          "water_reminder": formatter.checkValue(state.reminderWaterController.text),
          "meditation_time": formatter.checkValue(state.meditationController.text),
          "exercise_time": formatter.checkValue(state.exerciseController.text)
        });
      } else if (scheduleType == "Suppliments") {
        insertCall = _schedulerRepo.insertSupplimentSchedule(data: {
          "user_id": prefs.getString("userId"),
          "day": formatter.checkValue(state.dayController.text),
          "supplements": state.supplementControllers.map((e) {
            return {
              "supplement_name": e.supplementNameController.text.trim(),
              "time_slot": e.timeSlotController.text.trim(),
              "time": e.timeController.text.trim(),
            };
          }).toList()
        });
      } else {
        throw Exception("Invalid scheduleType: $scheduleType");
      }

      await insertCall.then((value) {
        log("$scheduleType insertion success!");
        showCustomPopup(
          context,
          title: value["status"],
          message: value["message"],
          iconData: value['status'] == "success" ? Icons.check : Icons.info_outline,
          okButtonText: 'Ok',
          onOkPressed: () {
            NavigationWidget.commonNavigatioPop(context: context);
          },
          cancelButtonText: '',
          onCancelPressed: null,
        );
      });

      state = state.copyWith(isDailyScheduleLoading: false);
    } on DioException catch (e) {
      log("Error inserting $scheduleType: ${e.message}");
      state = state.copyWith(isDailyScheduleLoading: false);
      showCustomPopup(
        context,
        title: "Something went wrong!",
        message: e.message.toString(),
        iconData: Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
      );
    }
  }

  // Function to get all the scheduler & reminder based on day
  Future<void> getFullSchedulerByDay(BuildContext context) async {
    try {
      state = state.copyWith(
        isAllScheduleLoading: true,
      );
      await _schedulerRepo.getFullSchedule(data: {
        "user_id": prefs.getString("userId"),
        "day": "Tuesday",
      }).then(
        (value) {
          state = state.copyWith(
            isAllScheduleLoading: false,
          );
          if (value.data != null) {
            log("Got Full Scheduler Success : ${value.data}");
            state = state.copyWith(
              getFullScheduleModel: value,
            );
            // Setting value for reminders
            if (state.getFullScheduleModel.data?.reminders != null) {
              state.copyWith(
                reminderDayController: TextEditingController(
                    text: formatter.checkValue(
                  state.getFullScheduleModel.data?.reminders?.day,
                )),
                reminderWaterController: TextEditingController(
                    text: formatter.checkValue(
                  state.getFullScheduleModel.data?.reminders?.waterReminder,
                )),
                meditationController: TextEditingController(
                    text: formatter.convertTo12HourFormat(formatter.checkValue(
                  state.getFullScheduleModel.data?.reminders?.meditationTime,
                ))),
                exerciseController: TextEditingController(
                    text: formatter.convertTo12HourFormat(formatter.checkValue(
                  state.getFullScheduleModel.data?.reminders?.exerciseTime,
                ))),
              );
            } else {
              clearReminders();
            }
            // Setting value for schedulers (Daily,Meal & Suppliment)
            if (state.getFullScheduleModel.data?.dailySchedule != null) {
              state = state.copyWith(
                dayController: TextEditingController(
                    text: formatter.checkValue(state.getFullScheduleModel.data?.dailySchedule?.day)),
                workoutController: TextEditingController(
                    text: formatter.checkValue(state.getFullScheduleModel.data?.dailySchedule?.workout)),
                fromTimeController: TextEditingController(
                    text: formatter.convertTo12HourFormat(
                        formatter.checkValue(state.getFullScheduleModel.data?.dailySchedule?.workoutTimeFrom))),
                toTimeController: TextEditingController(
                    text: formatter.convertTo12HourFormat(
                        formatter.checkValue(state.getFullScheduleModel.data?.dailySchedule?.workoutTimeTo))),
              );
            } else {
              clearSchedulerControllers('daily');
            }
            if (state.getFullScheduleModel.data?.mealSchedule != null) {
              state = state.copyWith(
                breakfastTimeController: TextEditingController(
                    text: formatter.checkValue(state.getFullScheduleModel.data?.mealSchedule?.breakfast)),
                midMorningSnackTimeController: TextEditingController(
                    text: formatter.checkValue(state.getFullScheduleModel.data?.mealSchedule?.midMorningSnack)),
                lunchTimeController: TextEditingController(
                    text: formatter.convertTo12HourFormat(
                        formatter.checkValue(state.getFullScheduleModel.data?.mealSchedule?.lunch))),
                preWorkoutTimeController: TextEditingController(
                    text: formatter.convertTo12HourFormat(
                        formatter.checkValue(state.getFullScheduleModel.data?.mealSchedule?.preWorkout))),
                postWorkoutTimeController: TextEditingController(
                    text: formatter.convertTo12HourFormat(
                        formatter.checkValue(state.getFullScheduleModel.data?.mealSchedule?.postWorkout))),
                dinnerTimeController: TextEditingController(
                    text: formatter.convertTo12HourFormat(
                        formatter.checkValue(state.getFullScheduleModel.data?.mealSchedule?.dinner))),
              );
            } else {
              clearSchedulerControllers('meal');
            }
            if ((state.getFullScheduleModel.data?.supplements?.isNotEmpty ?? false) ||
                state.getFullScheduleModel.data?.supplements != null) {
              final supplementList = mapSupplementsToControllers(state.getFullScheduleModel.data!.supplements);
              state = state.copyWith(supplementControllers: supplementList);
            } else {
              clearSchedulerControllers('supplement');
            }
          }
        },
      );
    } on DioException catch (e) {
      log("Error messge of scheduler : ${e.message}");
      showCustomPopup(
        context,
        title: "Something went wrong!",
        message: e.message.toString(),
        iconData: Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
      );
      state = state.copyWith(
        isAllScheduleLoading: false,
      );
    }
  }

  List<SupplementScheduleEntity> mapSupplementsToControllers(List<Supplement>? supplements) {
    if (supplements == null) return [SupplementScheduleEntity()];

    return supplements.map((s) {
      final controller = SupplementScheduleEntity();
      controller.supplementNameController.text = s.supplementName ?? '';
      controller.timeSlotController.text = s.timeSlot ?? '';
      controller.timeController.text =
          formatter.convertTo12HourFormat(formatter.checkValue(s.time)); // format to "8:00 AM"
      return controller;
    }).toList();
  }

  void onAddSchedulerTap(BuildContext context) {
    NavigationWidget.commonNavigation(
      context: context,
      route: AppRoutesConstants.addViewSchedulerRoute,
    );
  }

  void onDayDropDown({
    required String type,
    required String value,
  }) {
    if (type == "Reminder Day") {
      state = state.copyWith(
        reminderDayController: TextEditingController(text: value),
      );
      validateFields();
    } else {
      state = state.copyWith(
        dayController: TextEditingController(text: value),
      );
    }
  }

  void updateSupplementTime(String time) {
    state = state.copyWith(
      selectedSupplementTime: time,
      supplimentTimeController: TextEditingController(
        text: formatter.checkValue(time),
      ),
    );
    validateFields();
  }

  void onToggleChange({
    required String type,
    required bool value,
  }) {
    bool? water;
    bool? meditation;
    bool? exercise;

    if (type == "Water") {
      water = value;
    } else if (type == "Meditation") {
      meditation = value;
    } else if (type == "Exercise") {
      exercise = value;
    } else {
      log("nothing");
    }

    state = state.copyWith(
      isWaterToggle: water,
      isMeditationToggle: meditation,
      isExerciseToggle: exercise,
    );
    validateFields();
  }

  onSelectedScheduledTime(
    BuildContext context, {
    required String screenType,
    int? supplementIndex, // for supplements
  }) {
    // Determine existing time based on screenType
    String existingTime = '';
    final currentState = state;

    switch (screenType) {
      case 'Daily From':
        existingTime = currentState.fromTimeController.text;
        break;
      case 'Daily To':
        existingTime = currentState.toTimeController.text;
        break;
      case 'Breakfast':
        existingTime = currentState.breakfastTimeController.text;
        break;
      case 'Mid-Morning Snack':
        existingTime = currentState.midMorningSnackTimeController.text;
        break;
      case 'Lunch':
        existingTime = currentState.lunchTimeController.text;
        break;
      case 'Pre-Workout':
        existingTime = currentState.preWorkoutTimeController.text;
        break;
      case 'Post-Workout':
        existingTime = currentState.postWorkoutTimeController.text;
        break;
      case 'Dinner':
        existingTime = currentState.dinnerTimeController.text;
        break;
      case 'Water':
        existingTime = currentState.reminderWaterController.text;
        break;
      case 'Meditation':
        existingTime = currentState.meditationController.text;
        break;
      case 'Exercise':
        existingTime = currentState.meditationController.text;
        break;
      case 'Supplement Time':
        if (supplementIndex != null && supplementIndex < currentState.supplementControllers.length) {
          existingTime = currentState.supplementControllers[supplementIndex].timeController.text;
        }
        break;
    }

    // Open time picker with initial time
    CommonTimeWidget().selectTimeCommon(
      context: context,
      existingTime: existingTime,
      onTimeSelected: (formattedTime) {
        switch (screenType) {
          case 'Daily From':
            state = state.copyWith(
              fromTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Daily To':
            state = state.copyWith(
              toTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Breakfast':
            state = state.copyWith(
              breakfastTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Mid-Morning Snack':
            state = state.copyWith(
              midMorningSnackTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Lunch':
            state = state.copyWith(
              lunchTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Pre-Workout':
            state = state.copyWith(
              preWorkoutTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Post-Workout':
            state = state.copyWith(
              postWorkoutTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Dinner':
            state = state.copyWith(
              dinnerTimeController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Water':
            state = state.copyWith(
              reminderWaterController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Meditation':
            state = state.copyWith(
              meditationController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Exercise':
            state = state.copyWith(
              exerciseController: TextEditingController(text: formattedTime),
            );
            break;
          case 'Supplement Time':
            if (supplementIndex != null && supplementIndex < state.supplementControllers.length) {
              final updatedList = [...state.supplementControllers];
              final updatedController = updatedList[supplementIndex];
              // Update the controller's text directly
              updatedController.timeController.text = formattedTime;
              log("time updated to controller : ${updatedController.timeController.text}");

              // Update the state
              state = state.copyWith(supplementControllers: updatedList);
            } else {
              log("error is selecting suppliment time");
            }
            break;
        }
        validateFields();
      },
    );
  }

  void validateFields() {
    final day = state.reminderDayController.text.trim();
    final water = state.reminderWaterController.text.trim();
    final meditation = state.meditationController.text.trim();
    final exercise = state.exerciseController.text.trim();
    final supplement = state.selectedSupplementTime.trim();

    // Check required fields
    if (day.isEmpty || water.isEmpty || meditation.isEmpty || exercise.isEmpty || supplement.isEmpty) {
      state = state.copyWith(
        isReminderValidation: false,
      );
    } else {
      state = state.copyWith(
        isReminderValidation: true,
      );
    }

    log("validate : ${state.isReminderValidation}, $supplement");
  }

  void clearReminders() {
    state.reminderWaterController.clear();
    state.meditationController.clear();
    state.exerciseController.clear();
    state = state.copyWith(
      reminderDayController: TextEditingController(text: "Select day"),
      selectedSupplementTime: "Morning",
    );
    validateFields();
  }

  void clearSchedulerControllers(String section) {
    switch (section) {
      case 'daily':
        state.dayController.clear();
        state.workoutController.clear();
        state.workoutTimeController.clear();
        state.fromTimeController.clear();
        state.toTimeController.clear();
        break;

      case 'meal':
        state.breakfastTimeController.clear();
        state.midMorningSnackTimeController.clear();
        state.lunchTimeController.clear();
        state.preWorkoutTimeController.clear();
        state.postWorkoutTimeController.clear();
        state.dinnerTimeController.clear();
        break;

      case 'supplement':
        for (var supplement in state.supplementControllers) {
          supplement.supplementNameController.clear();
          supplement.timeSlotController.clear();
          supplement.timeController.clear();
        }
        break;

      default:
        throw Exception("Invalid section name: $section. Use 'daily', 'meal', or 'supplement'.");
    }
  }

  // Functions for the gym schedulers------------------------------

  // Function to save weekly schedule
  Future<void> saveWeeklySchedule(BuildContext context) async {
    try {
      state = state.copyWith(isSaveWeeklyLoading: true);

      final value = await _schedulerRepo.saveWeeklyScheduleRepo(
        data: generateGymSchedulePayload(
          userId: formatter.checkValue(prefs.getString("userId")),
          selectedWorkouts: state.selectedWorkoutsPerDay,
          fromTimeControllers: state.gymFromTimeControllers,
          toTimeControllers: state.gymToTimeControllers,
        ),
      );

      final status = value['status'].toString();
      final message = value['message'] ?? "No message";

      log("Save Weekly  Response: $value");

      showCustomPopup(
        context,
        title: status == "success" ? "Success" : "Error",
        message: message,
        iconData: status == "success" ? Icons.check : Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
        onOkPressed: () {
          NavigationWidget.commonNavigatioPop(context: context);
          if (status == "success") {
            context.read<ProfileBloc>().add(ChangeTabIndex(2));
            CustomSmoothNavigator.pushReplacement(context, MainScreen());
          }
        },
      );
    } catch (e) {
      log("Exception in requestGymPartner: $e");
      showCustomPopup(
        context,
        title: "Something went wrong!",
        message: e.toString(),
        iconData: Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
      );
    } finally {
      state = state.copyWith(isSaveWeeklyLoading: false);
    }
  }

  void toggleWorkoutSelection(String day, String workout) {
    final selectedList = List<String>.from(state.selectedWorkoutsPerDay[day] ?? []);
    if (selectedList.contains(workout)) {
      selectedList.remove(workout);
    } else {
      selectedList.add(workout);
    }

    state = state.copyWith(
      selectedWorkoutsPerDay: {
        ...state.selectedWorkoutsPerDay,
        day: selectedList,
      },
    );
    gymScheduleValid();
  }

  // Function to get today workout
  Future<void> getTodayWorkOutSchedule(BuildContext context) async {
    try {
      state = state.copyWith(
        isTodayWorkOutLoading: true,
      );
      await _schedulerRepo.getTodaysWorkOutRepo(data: {
        "user_id": formatter.checkValue(prefs.getString("userId")),
      }).then(
        (value) {
          log("Success today schedule $value");
          state = state.copyWith(
            getTodayWorkOutList: value,
          );
        },
      );
    } catch (e) {
      showCustomPopup(
        context,
        title: "Something went wrong!",
        message: e.toString(),
        iconData: Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
      );
    } finally {
      state = state.copyWith(
        isTodayWorkOutLoading: false,
      );
    }
  }

  // Function to get weekly progress
  Future<void> getWeeklyProgress(BuildContext context) async {
    try {
      state = state.copyWith(
        isWeeklyProgressLoading: true,
      );
      await _schedulerRepo.getWeeklyProgressRepo(data: {
        "user_id": formatter.checkValue(prefs.getString("userId")),
      }).then(
        (value) {
          log("Success weekly progress $value");
          state = state.copyWith(
            getWeeklyProgressList: value,
          );
        },
      );
    } catch (e) {
      showCustomPopup(
        context,
        title: "Something went wrong!",
        message: e.toString(),
        iconData: Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
      );
    } finally {
      state = state.copyWith(
        isWeeklyProgressLoading: false,
      );
    }
  }

// Update gymScheduleValid():
  void gymScheduleValid() {
    for (final day in state.selectedWorkoutsPerDay.keys) {
      final workouts = state.selectedWorkoutsPerDay[day] ?? [];
      final from = state.gymFromTimeControllers[day]?.text.trim() ?? '';
      final to = state.gymToTimeControllers[day]?.text.trim() ?? '';

      if (workouts.isNotEmpty && from.isNotEmpty && to.isNotEmpty) {
        state = state.copyWith(isGymScheduleValid: true);
        return;
      }
    }
    state = state.copyWith(isGymScheduleValid: false);
  }

// Update save payload
  Map<String, dynamic> generateGymSchedulePayload({
    required String userId,
    required Map<String, List<String>> selectedWorkouts,
    required Map<String, TextEditingController> fromTimeControllers,
    required Map<String, TextEditingController> toTimeControllers,
  }) {
    final schedule = selectedWorkouts.keys.map((day) {
      return {
        "day": day,
        "workout": selectedWorkouts[day] ?? [],
        "workout_time_from": fromTimeControllers[day]?.text ?? "",
        "workout_time_to": toTimeControllers[day]?.text ?? "",
      };
    }).toList();

    return {
      "user_id": userId,
      "schedule": schedule,
    };
  }

  void onSelectTimeForGymSchedule(
    BuildContext context,
    TextEditingController controller,
  ) {
    final commonTimeWidget = CommonTimeWidget();

    commonTimeWidget.selectTimeCommon(
      context: context,
      existingTime: controller.text,
      onTimeSelected: (formattedTime) {
        controller.text = formattedTime;

        // Trigger rebuild if needed
        state = state.copyWith();
      },
    );
    gymScheduleValid();
  }

  void clearGymScheduleControllers() {
    for (final day in state.gymWorkoutControllers.keys) {
      state.gymWorkoutControllers[day]?.clear();
      state.gymFromTimeControllers[day]?.clear();
      state.gymToTimeControllers[day]?.clear();
    }
    state = state.copyWith(isGymScheduleValid: false);
  }

  void startGreetingTimer() {
    _updateGreeting(); // initial greeting

    _greetingTimer?.cancel(); // prevent duplicates
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateGreeting();
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = "Good Morning! 👋";
    } else if (hour < 17) {
      greeting = "Good Afternoon! 👋";
    } else {
      greeting = "Good Evening! 👋";
    }

    state = state.copyWith(greetingMessage: greeting);
  }

  onRefreshGymSchedule(BuildContext context) async {
    await getWeeklyProgress(context);
    await getTodayWorkOutSchedule(context);
  }
}
