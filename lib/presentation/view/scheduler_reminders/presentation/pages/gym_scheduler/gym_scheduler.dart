import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';

class GymSchedulerScreen extends ConsumerStatefulWidget {
  const GymSchedulerScreen({super.key});

  @override
  ConsumerState<GymSchedulerScreen> createState() => _GymSchedulerScreenState();
}

class _GymSchedulerScreenState extends ConsumerState<GymSchedulerScreen> {
  final List<String> daysOfWeek = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> allWorkouts = const [
    'Off today',
    'Chest Exercises',
    'Back Exercises',
    'Shoulder Exercises',
    'Biceps Exercises',
    'Triceps Exercises',
    'Leg Exercises',
    'Calf Exercises',
    'Ab & Core Exercises',
    'Cardio Machines',
    'Full-Body / Functional Movements',
    'Bodyweight Exercises',
    'CrossFit/HIIT Style Movements',
  ];

  final PageController _pageController = PageController();
  final ScrollController scrollController = ScrollController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final schedulerState = ref.watch(DiProviders.schedulerControllerProvider);
    final schedulerProvider = ref.read(DiProviders.schedulerControllerProvider.notifier);

    return Scaffold(
      appBar: CommonAppBar(
        title: "Add Gym Schedule",
        titleStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: Padding(
        padding: AppPaddings.backgroundPAll,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentPage + 1) / daysOfWeek.length,
              backgroundColor: Colors.grey.shade300,
              color: AppColors.kPrimaryColor,
              minHeight: 6,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daysOfWeek.length,
                itemBuilder: (context, index) {
                  final day = daysOfWeek[index];
                  final selectedList = schedulerState.selectedWorkoutsPerDay[day] ?? [];
                  final scrollController = ScrollController();
                  return SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 280),
                            child: Scrollbar(
                              controller: scrollController,
                              thumbVisibility: true,
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: allWorkouts.length,
                                itemBuilder: (context, i) {
                                  final workout = allWorkouts[i];
                                  final isSelected = selectedList.contains(workout);
                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(workout, style: const TextStyle(fontSize: 14)),
                                    onChanged: (_) {
                                      schedulerProvider.toggleWorkoutSelection(day, workout);
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    activeColor: AppColors.kPrimaryColor,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  readOnly: true,
                                  controller: schedulerState.gymFromTimeControllers[day],
                                  hintText: 'From Time',
                                  validator: (_) => null,
                                  onTap: () => schedulerProvider.onSelectTimeForGymSchedule(
                                    context,
                                    schedulerState.gymFromTimeControllers[day]!,
                                  ),
                                  keyboard: TextInputType.none,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomTextFormField(
                                  readOnly: true,
                                  controller: schedulerState.gymToTimeControllers[day],
                                  hintText: 'To Time',
                                  validator: (_) => null,
                                  onTap: () => schedulerProvider.onSelectTimeForGymSchedule(
                                    context,
                                    schedulerState.gymToTimeControllers[day]!,
                                  ),
                                  keyboard: TextInputType.none,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentPage > 0)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() => _currentPage--);
                                    _pageController.previousPage(
                                        duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                  },
                                  child: const Text("Previous"),
                                ),
                              ElevatedButton(
                                onPressed: () {
                                  if (_currentPage < daysOfWeek.length - 1) {
                                    setState(() => _currentPage++);
                                    _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                  } else {
                                    schedulerProvider.saveWeeklySchedule(context);
                                  }
                                },
                                child: Text(_currentPage == daysOfWeek.length - 1 ? "Save" : "Next"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
