import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_dropdowns/common_dropdowns.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProviderScope.containerOf(context)
          .read(DiProviders.schedulerControllerProvider.notifier)
          .getFullSchedulerByDay(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final schedulerState = ref.watch(DiProviders.schedulerControllerProvider);
        final schedulerProvider = ref.read(DiProviders.schedulerControllerProvider.notifier);

        return Scaffold(
          appBar: const CommonAppBar(
            title: "Daily Reminders",
          ),
          body: SafeArea(
            child: schedulerState.isAllScheduleLoading
                ? const CommonLoadingWidget()
                : Padding(
                    padding: AppPaddings.backgroundPAll,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay on track with personalized notifications',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          AppSize.kHeight15,

                          /// Icon header
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: const BoxDecoration(
                                color: AppColors.kPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications, size: 40, color: AppColors.kWhite),
                            ),
                          ),

                          /// Day Field
                          CommonTwoHeaderColumnTileWidget(
                            headerTitle: 'Day',
                            subWidget: CommonDropDownWidget(
                              items: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                              hintText: "Select day",
                              primaryValue: schedulerState.reminderDayController.text,
                              widgetIcon: Icon(
                                Icons.calendar_month_outlined,
                              ),
                              onDropDwChanged: (val) {
                                schedulerProvider.onDayDropDown(type: "Reminder Day", value: val ?? '');
                              },
                            ),
                          ),
                          AppSize.kHeight15,

                          /// Water Reminder
                          CommonTwoHeaderColumnTileWidget(
                            headerTitle: 'Water Reminder',
                            subWidget: CustomTextFormField(
                              controller: schedulerState.reminderWaterController,
                              validator: (_) => null,
                              keyboard: TextInputType.text,
                              hintText: 'Every 2 hours',
                              onChanged: (p0) {
                                schedulerProvider.validateFields();
                              },
                            ),
                          ),
                          AppSize.kHeight10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Enable Water Reminder', style: TextStyle(fontSize: 16)),
                              CommonToggleButton(
                                value: schedulerState.isWaterToggle,
                                onChanged: (val) {
                                  schedulerProvider.onToggleChange(type: "Water", value: val);
                                },
                                isYesNo: false,
                              ),
                            ],
                          ),
                          AppSize.kHeight15,

                          /// Meditation Reminder
                          CommonTwoHeaderColumnTileWidget(
                            headerTitle: 'Meditation Time',
                            subWidget: CustomTextFormField(
                              controller: schedulerState.meditationController,
                              readOnly: true,
                              validator: (_) => null,
                              keyboard: TextInputType.text,
                              hintText: '6:00 AM',
                              preffix: Icon(
                                CupertinoIcons.clock,
                              ),
                              onTap: () {
                                schedulerProvider.onSelectedScheduledTime(context, screenType: "Meditation");
                              },
                            ),
                          ),
                          AppSize.kHeight10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Enable Meditation Reminder', style: TextStyle(fontSize: 16)),
                              CommonToggleButton(
                                value: schedulerState.isMeditationToggle,
                                onChanged: (val) {
                                  schedulerProvider.onToggleChange(type: "Meditation", value: val);
                                },
                                isYesNo: false,
                              ),
                            ],
                          ),
                          AppSize.kHeight15,

                          /// Exercise Reminder
                          CommonTwoHeaderColumnTileWidget(
                            headerTitle: 'Exercise Time',
                            subWidget: CustomTextFormField(
                              controller: schedulerState.exerciseController,
                              readOnly: true,
                              validator: (_) => null,
                              keyboard: TextInputType.text,
                              hintText: '8:00 PM',
                              preffix: Icon(
                                CupertinoIcons.clock,
                              ),
                              onTap: () {
                                schedulerProvider.onSelectedScheduledTime(context, screenType: "Exercise");
                              },
                            ),
                          ),
                          AppSize.kHeight10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Enable Exercise Reminder', style: TextStyle(fontSize: 16)),
                              CommonToggleButton(
                                value: schedulerState.isExerciseToggle,
                                onChanged: (val) {
                                  schedulerProvider.onToggleChange(type: "Exercise", value: val);
                                },
                                isYesNo: false,
                              ),
                            ],
                          ),
                          AppSize.kHeight15,

                          /// Supplements
                          const Text(
                            'Select Supplement Time',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          AppSize.kHeight10,
                          Wrap(
                            spacing: 8,
                            children: ['Morning', 'Afternoon', 'Evening'].map((time) {
                              final isSelected = schedulerState.selectedSupplementTime == time;
                              return ChoiceChip(
                                label: Text(
                                  time,
                                ),
                                showCheckmark: false,
                                selected: isSelected,
                                selectedColor: AppColors.kPrimaryColor,
                                shape: StadiumBorder(),
                                backgroundColor: AppColors.kWhite,
                                labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: isSelected ? AppColors.kWhite : AppColors.kBlack,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                    ),
                                onSelected: (val) {
                                  if (val) {
                                    schedulerProvider.updateSupplementTime(time);
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          AppSize.kHeight30,
                        ],
                      ),
                    )),
          ),
          bottomNavigationBar: CommonBottomButtonWidget(
            padding: AppPaddings.bottomnavP,
            leftButtonText: 'Add Scheduler',
            rightButtonText: 'Save Reminder',
            leftBackgroundColor: AppColors.kWhite,
            leftBorderColor: AppColors.kPrimaryColor.withValues(alpha: 0.5),
            onLeftButtonPressed: () {
              schedulerProvider.onAddSchedulerTap(context);
            },
            onRightButtonPressed: () {
              schedulerProvider.insertAllDailySchedule(context, scheduleType: "Daily Reminder");
            },
            isAbsorbing: false,
            isLeftButtonLoading: false,
            isRightButtonLoading: schedulerState.isDailyScheduleLoading,
            isRightButtonEnabled: !schedulerState.isReminderValidation,
          ),
        );
      },
    );
  }
}
