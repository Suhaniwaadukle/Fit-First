import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_dropdowns/common_dropdowns.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/domain/entities/scheduler_entity.dart';

class AddViewSchedulerScreen extends StatefulWidget {
  const AddViewSchedulerScreen({super.key});

  @override
  State<AddViewSchedulerScreen> createState() => _AddViewSchedulerScreenState();
}

class _AddViewSchedulerScreenState extends State<AddViewSchedulerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final schedulerState = ref.watch(DiProviders.schedulerControllerProvider);
      final schedulerProvider = ref.watch(DiProviders.schedulerControllerProvider.notifier);
      return Scaffold(
        appBar: CommonAppBar(
          title: "Add Scheduler",
        ),
        body: SingleChildScrollView(
          padding: AppPaddings.backgroundPAll,
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Daily Schedule'),
              CommonTwoHeaderColumnTileWidget(
                headerTitle: 'Day',
                subWidget: CommonDropDownWidget(
                  items: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                  hintText: "Select day",
                  primaryValue: schedulerState.dayController.text,
                  widgetIcon: Icon(
                    Icons.calendar_month_outlined,
                  ),
                  onDropDwChanged: (val) {
                    schedulerProvider.onDayDropDown(type: "Scheduler Day", value: val ?? '');
                  },
                ),
              ),
              CommonTwoHeaderColumnTileWidget(
                headerTitle: 'Workout',
                subWidget: CustomTextFormField(
                  controller: schedulerState.workoutController,
                  validator: (_) => null,
                  keyboard: TextInputType.text,
                  hintText: 'Back & Biceps',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: CommonTwoHeaderColumnTileWidget(
                      headerTitle: 'From',
                      subWidget: CustomTextFormField(
                        readOnly: true,
                        controller: schedulerState.fromTimeController,
                        validator: (_) => null,
                        keyboard: TextInputType.datetime,
                        hintText: '6:00 AM',
                        onTap: () {
                          schedulerProvider.onSelectedScheduledTime(context, screenType: "Daily From");
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonTwoHeaderColumnTileWidget(
                      headerTitle: 'To',
                      subWidget: CustomTextFormField(
                        controller: schedulerState.toTimeController,
                        readOnly: true,
                        validator: (_) => null,
                        keyboard: TextInputType.datetime,
                        hintText: '7:30 AM',
                        onTap: () {
                          schedulerProvider.onSelectedScheduledTime(context, screenType: "Daily To");
                        },
                      ),
                    ),
                  ),
                ],
              ),
              AppSize.kHeight10,
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  text: "Add Daily Schedule",
                  isLoading: schedulerState.isDailyScheduleLoading,
                  borderRadius: BorderRadius.circular(15),
                  backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                  onPressed: () {
                    schedulerProvider.insertAllDailySchedule(
                      context,
                      scheduleType: "Daily Schedule",
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle('Meal Schedule'),
              ...[
                'Breakfast',
                'Mid-Morning Snack',
                'Lunch',
                'Pre-Workout',
                'Post-Workout',
                'Dinner',
              ].map(
                (label) => CommonTwoHeaderColumnTileWidget(
                  headerTitle: label,
                  subWidget: CustomTextFormField(
                    controller: _getMealController(
                      labelText: label,
                      state: schedulerState,
                    ),
                    validator: (_) => null,
                    readOnly: true,
                    keyboard: TextInputType.datetime,
                    hintText: 'Enter Time',
                    onTap: () {
                      schedulerProvider.onSelectedScheduledTime(
                        context,
                        screenType: label,
                      );
                    },
                  ),
                ),
              ),
              AppSize.kHeight10,
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  text: "Add Meal Schedule",
                  isLoading: schedulerState.isDailyScheduleLoading,
                  borderRadius: BorderRadius.circular(15),
                  backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                  onPressed: () {
                    schedulerProvider.insertAllDailySchedule(
                      context,
                      scheduleType: "Meal Schedule",
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Supplement Schedule'),
                  CommonIconWidget(
                    icon: Icons.add_circle,
                    size: 35,
                    onPressed: () {
                      setState(() {
                        schedulerState.supplementControllers.add(SupplementScheduleEntity());
                      });
                    },
                  ),
                ],
              ),
              ...schedulerState.supplementControllers.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CommonContainerWithBorder(
                      radius: 10,
                      child: Column(
                        spacing: 10,
                        children: [
                          CommonTwoHeaderColumnTileWidget(
                            headerTitle: 'Supplement Name',
                            subWidget: CustomTextFormField(
                              controller: controller.supplementNameController,
                              validator: (_) => null,
                              maxLines: 2,
                              keyboard: TextInputType.text,
                              hintText: 'Whey Protein',
                            ),
                          ),
                          Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: CommonTwoHeaderColumnTileWidget(
                                  headerTitle: 'Time Slot',
                                  subWidget: CustomTextFormField(
                                    controller: controller.timeSlotController,
                                    validator: (_) => null,
                                    keyboard: TextInputType.text,
                                    hintText: 'Morning',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: CommonTwoHeaderColumnTileWidget(
                                  headerTitle: 'Time',
                                  subWidget: CustomTextFormField(
                                    controller: controller.timeController,
                                    readOnly: true,
                                    validator: (_) => null,
                                    keyboard: TextInputType.datetime,
                                    hintText: '8:00 AM',
                                    onTap: () {
                                      schedulerProvider.onSelectedScheduledTime(
                                        context,
                                        screenType: 'Supplement Time',
                                        supplementIndex: index,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (schedulerState.supplementControllers.length > 1)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      schedulerState.supplementControllers.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.kPrimaryColor,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  text: "Add Suppliment Schedule",
                  isLoading: schedulerState.isDailyScheduleLoading,
                  borderRadius: BorderRadius.circular(15),
                  backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                  onPressed: () {
                    schedulerProvider.insertAllDailySchedule(
                      context,
                      scheduleType: "Suppliments",
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  TextEditingController? _getMealController({
    required String labelText,
    required SchedulerEntity state,
  }) {
    switch (labelText) {
      case 'Breakfast':
        return state.breakfastTimeController;
      case 'Mid-Morning Snack':
        return state.midMorningSnackTimeController;
      case 'Lunch':
        return state.lunchTimeController;
      case 'Pre-Workout':
        return state.preWorkoutTimeController;
      case 'Post-Workout':
        return state.postWorkoutTimeController;
      case 'Dinner':
        return state.dinnerTimeController;
      default:
        return null;
    }
  }
}
