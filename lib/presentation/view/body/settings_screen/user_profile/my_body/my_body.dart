// import 'package:flutter/material.dart';
// import 'package:numberpicker/numberpicker.dart';
// import 'package:orka_sports/core/constants/app_colors.dart';
// import 'package:orka_sports/core/constants/app_text_styles.dart';

// class _MyBodyScreenState extends StatefulWidget {
//   const _MyBodyScreenState();

//   @override
//   State<_MyBodyScreenState> createState() => __MyBodyScreenStateState();
// }

// class __MyBodyScreenStateState extends State<_MyBodyScreenState> {
//   int _currentStep = 0;
//   int _currentAge = 25;
//   int _currentHeight = 170;
//   int _currentWeight = 65;
//   String? _selectedGender;

//   Widget _buildNumberPicker({
//     required int value,
//     required ValueChanged<int> onChanged,
//     required int minValue,
//     required int maxValue,
//     required String suffix,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//       child: Column(
//         children: [
//           NumberPicker(
//             value: value,
//             minValue: minValue,
//             maxValue: maxValue,
//             onChanged: onChanged,
//             selectedTextStyle: TextStyle(
//               color: AppColors.primary,
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//             ),
//             textStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
//             itemHeight: 60,
//             itemWidth: 80,
//             decoration: BoxDecoration(
//               border: Border(
//                 top: BorderSide(color: Colors.grey.shade200, width: 2),
//                 bottom: BorderSide(color: Colors.grey.shade200, width: 2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               // ignore: deprecated_member_use
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               suffix,
//               style: TextStyle(
//                 color: AppColors.primary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// Widget _buildGenderCard(String gender, IconData icon) {
//   final isSelected = _selectedGender == gender;
//   return GestureDetector(
//     onTap: () => setState(() => _selectedGender = gender),
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
//       decoration: BoxDecoration(
//         // ignore: deprecated_member_use
//         color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isSelected ? AppColors.primary : Colors.grey.shade200,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 2,
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 44,
//             color: isSelected ? AppColors.primary : Colors.grey.shade400,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             gender,
//             style: TextStyle(
//               color: isSelected ? AppColors.primary : Colors.grey.shade600,
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'My Body',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: AppColors.primary,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: ColorScheme.light(
//             primary: AppColors.primary,
//             secondary: AppColors.primary,
//             surface: Colors.white,
//           ),
//           useMaterial3: true,
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//           iconTheme: IconThemeData(color: AppColors.primary, size: 28),
//         ),
//         child: Stepper(
//           currentStep: _currentStep,
//           onStepTapped: (step) => setState(() => _currentStep = step),
//           controlsBuilder: (context, controls) {
//             return Padding(
//               padding: const EdgeInsets.only(top: 32),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   if (_currentStep > 0)
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             // ignore: deprecated_member_use
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ElevatedButton(
//                         onPressed: controls.onStepCancel,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.grey.shade700,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 42,
//                             vertical: 16,
//                           ),
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             side: BorderSide(
//                               color: Colors.grey.shade200,
//                               width: 1.5,
//                             ),
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                         child: const Text(
//                           'Back',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//                   ElevatedButton(
//                     onPressed: controls.onStepContinue,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       _currentStep == 3 ? 'Finish' : 'Continue',
//                       style: AppTextStyles.button,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//           steps: [
//             Step(
//               title: const Text('Gender'),
//               content: SizedBox(
//                 width: double.infinity,
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 8,
//                     horizontal: 16,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 8),
//                           child: _buildGenderCard('Male', Icons.male),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.only(left: 8),
//                           child: _buildGenderCard('Female', Icons.female),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               isActive: _currentStep >= 0,
//             ),
//             Step(
//               title: const Text('Age'),
//               content: _buildNumberPicker(
//                 value: _currentAge,
//                 onChanged: (value) => setState(() => _currentAge = value),
//                 minValue: 1,
//                 maxValue: 100,
//                 suffix: 'Years',
//               ),
//               isActive: _currentStep >= 1,
//             ),
//             Step(
//               title: const Text('Height'),
//               content: _buildNumberPicker(
//                 value: _currentHeight,
//                 onChanged: (value) => setState(() => _currentHeight = value),
//                 minValue: 100,
//                 maxValue: 250,
//                 suffix: 'cm',
//               ),
//               isActive: _currentStep >= 2,
//             ),
//             Step(
//               title: const Text('Weight'),
//               content: _buildNumberPicker(
//                 value: _currentWeight,
//                 onChanged: (value) => setState(() => _currentWeight = value),
//                 minValue: 30,
//                 maxValue: 200,
//                 suffix: 'kg',
//               ),
//               isActive: _currentStep >= 3,
//             ),
//           ],
//           onStepContinue: () {
//             if (_currentStep < 3) {
//               setState(() => _currentStep++);
//             } else {
//               // Handle form submission
//             }
//           },
//           onStepCancel: () {
//             if (_currentStep > 0) {
//               setState(() => _currentStep--);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
