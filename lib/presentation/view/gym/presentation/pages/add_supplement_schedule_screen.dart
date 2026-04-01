import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_dropdowns/common_dropdowns.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/config/api_constants.dart';
import 'package:dio/dio.dart';

class AddSupplementScheduleScreen extends ConsumerStatefulWidget {
  final String userId;
  final String doshaResult;
  const AddSupplementScheduleScreen({
    super.key,
    required this.userId,
    required this.doshaResult,
  });

  @override
  ConsumerState<AddSupplementScheduleScreen> createState() => _AddSupplementScheduleScreenState();
}

class _AddSupplementScheduleScreenState extends ConsumerState<AddSupplementScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  String selectedDay = '';
  final List<SupplementEntry> _supplementEntries = [SupplementEntry()];
  bool _isLoading = false;

  Future<void> _pickTime(BuildContext context, SupplementEntry entry) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 8, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.kPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        entry.time = picked.format(context);
      });
    }
  }

  Future<void> _saveSupplementSchedule() async {
    if (selectedDay.isEmpty || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields."), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() { _isLoading = true; });

    final data = {
      "user_id": widget.userId,
      "day": selectedDay,
      "supplements": _supplementEntries.map((e) => {
        "supplement_name": e.nameController.text,
        "time_slot": e.slotController.text,
        "time": e.time,
      }).toList(),
    };

    try {
      final response = await Dio().post(
        ApiConstants.apiBaseUrl + ApiConstants.saveSuppliments,
        data: data,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.data["message"] ?? "Saved!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Close screen after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save supplement schedule."), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Add Supplement Schedule"),
      body: SafeArea(
      child: SingleChildScrollView(
        padding: AppPaddings.backgroundPAll,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Day", style: TextStyle(fontWeight: FontWeight.bold)),
              CommonDropDownWidget(
                items: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                hintText: "Select day",
                primaryValue: selectedDay,
                widgetIcon: Icon(Icons.calendar_month_outlined),
                onDropDwChanged: (val) {
                  setState(() { selectedDay = val ?? ''; });
                },
              ),
              const SizedBox(height: 20),
              ..._supplementEntries.asMap().entries.map((entry) {
                final i = entry.key;
                final e = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.14)),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: e.nameController,
                        decoration: InputDecoration(
                          labelText: "Supplement Name",
                          hintText: "Whey Protein",
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: e.slotController,
                        decoration: InputDecoration(
                          labelText: "Time Slot",
                          hintText: "Morning",
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Required" : null,
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _pickTime(context, e),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Time",
                              hintText: "8:00 AM",
                            ),
                            controller: TextEditingController(text: e.time),
                            validator: (v) => e.time.isEmpty ? "Required" : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_supplementEntries.length > 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _supplementEntries.removeAt(i);
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  text: "Add Another Supplement",
                  borderRadius: BorderRadius.circular(12),
                  backgroundColor: WidgetStatePropertyAll(AppColors.kWhite),
                  side: BorderSide(color: AppColors.kPrimaryColor),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.kPrimaryColor,
                    fontWeight: FontWeight.bold),
                  onPressed: () {
                    setState(() {
                      _supplementEntries.add(SupplementEntry());
                    });
                  },
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  text: "Add Suppliment Schedule",
                  isLoading: _isLoading,
                  borderRadius: BorderRadius.circular(15),
                  backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.kWhite, fontWeight: FontWeight.bold),
                  onPressed: _saveSupplementSchedule,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class SupplementEntry {
  final nameController = TextEditingController();
  final slotController = TextEditingController();
  String time = '';
}
