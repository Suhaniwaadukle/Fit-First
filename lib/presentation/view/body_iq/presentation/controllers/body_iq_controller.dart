// ignore_for_file: use_build_context_synchronously
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
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/diet_models/added_meal_item_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/diet_models/meal_recommendations_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/product_models/get_reco_products_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/repositories/body_iq_repo_impl.dart';
import 'package:orka_sports/presentation/view/body_iq/domain/entities/body_iq_entity.dart';
import 'package:orka_sports/presentation/view/body_iq/domain/repositories/body_iq_repo.dart';
import 'package:orka_sports/presentation/view/main_screen/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BodyIqController extends StateNotifier<BodyIqEntity> {
  BodyIqController() : super(BodyIqEntity.initial());

  final BodyIqRepo _bodyIqRepo = BodyIqRepoImpl();
  final CommonFormatter formatter = CommonFormatter();
  final SharedPreferences prefs = GetItService.getIt<SharedPreferences>();


  // ✅ ADD THESE LOADING FLAGS
  bool _hasDoshaResultLoaded = false;
  bool _hasLifestyleResultLoaded = false;
  bool _hasDoshaRecoLoaded = false;
  bool _hasRecoProductsLoaded = false;

    // ✅ ADD THIS NEW PARALLEL LOADING METHOD
  Future<void> loadAllBodyIQDataInParallel(BuildContext context) async {
    print("🧠 Starting BodyIQ parallel data loading...");
    final startTime = DateTime.now();
    
    try {
      // ✅ RUN ALL BODYIQ APIs IN PARALLEL
      await Future.wait([
        getDoshaResult(context),
        getLifeStyleResultFn(context),
        getRecoProducts(context),
        // Add other BodyIQ calls here if needed
      ]);
      
      final duration = DateTime.now().difference(startTime);
      print("🎉 BodyIQ parallel loading completed in ${duration.inMilliseconds}ms");
      
    } catch (e) {
      print("❌ Error in BodyIQ parallel loading: $e");
      // Don't throw error - let individual methods handle their own errors
    }
  }

  // ✅ FIXED: Load meal recommendations method
  Future<void> loadMealRecommendations(BuildContext context, {
    required String userId,
    required String doshaResult,
    required int foodType,
  }) async {
    try {
      state = state.copyWith(isDietLoading: true, dietError: null);
      
      // Use _bodyIqRepo directly instead of ref.read()
      final breakfastRecommendations = await _bodyIqRepo.getFoodItemsByMealAndDosha(
        userId: userId,
        doshaResult: doshaResult,
        meal: 'Breakfast',
        foodType: foodType,
      );
      
      final lunchRecommendations = await _bodyIqRepo.getFoodItemsByMealAndDosha(
        userId: userId,
        doshaResult: doshaResult,
        meal: 'Lunch',
        foodType: foodType,
      );
      
      final snackRecommendations = await _bodyIqRepo.getFoodItemsByMealAndDosha(
        userId: userId,
        doshaResult: doshaResult,
        meal: 'Snack',
        foodType: foodType,
      );
      
      final dinnerRecommendations = await _bodyIqRepo.getFoodItemsByMealAndDosha(
        userId: userId,
        doshaResult: doshaResult,
        meal: 'Dinner',
        foodType: foodType,
      );
      
      final dailyMealData = DailyMealData(
        date: DateTime.now().toIso8601String().split('T')[0],
        mealRecommendations: {
          'Breakfast': breakfastRecommendations,
          'Lunch': lunchRecommendations,
          'Snack': snackRecommendations,
          'Dinner': dinnerRecommendations,
        },
        selectedMealItems: {
          'Breakfast': [],
          'Lunch': [],
          'Snack': [],
          'Dinner': [],
        },
      );
      
      state = state.copyWith(isDietLoading: false, dailyMealData: dailyMealData);
    } catch (e) {
      state = state.copyWith(isDietLoading: false, dietError: e.toString());
    }
  }

  // ✅ ADDED: Missing method for dynamic food type selection
  Future<MealRecommendationsResponse> getFoodItemsByMealAndDosha({
    required String userId,
    required String meal,
    required int foodType,
    String? doshaResult,
  }) async {
    try {
      print('=== CONTROLLER: Getting food items by meal and dosha ===');
      print('User ID: $userId');
      print('Meal: $meal');
      print('Food Type: $foodType');

      // ✅ FIXED: Properly handle nullable dosha with null check
      String dosha = _resolveDoshaResult(doshaResult);
      print('Resolved dosha: $dosha');
      
      final response = await _bodyIqRepo.getFoodItemsByMealAndDosha(
        userId: userId,
        doshaResult: dosha, // ✅ Now guaranteed to be non-null
        meal: meal,
        foodType: foodType,
      );
      
      print('=== CONTROLLER: Received ${response.items.length} items ===');
      return response;
      
    } catch (e) {
      print('=== CONTROLLER: Error getting food items ===');
      print('Error: $e');
      throw e;
    }
  }

  // ✅ ADDED: Helper method for dosha resolution
  String _resolveDoshaResult(String? providedDosha) {
    // Priority 1: Use provided dosha if valid
    if (providedDosha != null && providedDosha.trim().isNotEmpty) {
      return providedDosha.trim().toLowerCase();
    }
    
    // Priority 2: Use dosha from state if available
    try {
      final stateDoshaResult = state.getDoshaResultModel?.dominantDosha;
      if (stateDoshaResult != null && stateDoshaResult.isNotEmpty) {
        return stateDoshaResult.toLowerCase();
      }
    } catch (e) {
      print('Error accessing dosha from state: $e');
    }
    
    // Priority 3: Use default dosha
    print('Warning: No dosha result available, using default');
    return 'vata'; // Default fallback
  }

Future<void> addSelectedFoodToMeal({
  required BuildContext context,
  required String userId,
  required String meal,
  required List<FoodRecommendation> selectedItems,
  required String day,
}) async {
  await _addFoodWithConflictHandling(
    context: context,
    userId: userId,
    meal: meal,
    selectedItems: selectedItems,
    day: day,
    forceReplace: false, // ✅ INITIAL CALL WITH FALSE
  );
}

// ✅ NEW PRIVATE METHOD TO HANDLE THE CONDITIONAL LOGIC
Future<void> _addFoodWithConflictHandling({
  required BuildContext context,
  required String userId,
  required String meal,
  required List<FoodRecommendation> selectedItems,
  required String day,
  required bool forceReplace,
}) async {
  try {
    state = state.copyWith(isAddingFood: true);
    
    // Convert FoodRecommendation items to item IDs
    final itemIds = selectedItems.map((item) => int.parse(item.itemId)).toList();
    
    print('=== ADDING FOOD TO MEAL ===');
    print('User ID: $userId');
    print('Meal: $meal');
    print('Item IDs: $itemIds');
    print('Day: $day');
    print('Force Replace: $forceReplace');
    
    // ✅ API CALL WITH FORCE REPLACE PARAMETER
    final response = await _bodyIqRepo.addFoodItemToMeal(
      userId: userId,
      meal: meal,
      itemIds: itemIds,
      day: day,
      forceReplaceGym: forceReplace, // ✅ PASS THE PARAMETER
    );
    
    // ✅ CHECK FOR GYM CONFLICT MESSAGE
    if (!forceReplace && response.message.contains("You already have items in Gym tab. If you continue, Gym items will be removed.")) {
      state = state.copyWith(isAddingFood: false);
      
      // ✅ SHOW CONFIRMATION DIALOG
      final shouldContinue = await _showGymConflictDialog(context);
      
      if (shouldContinue) {
        // ✅ RETRY WITH FORCE REPLACE = TRUE
        await _addFoodWithConflictHandling(
          context: context,
          userId: userId,
          meal: meal,
          selectedItems: selectedItems,
          day: day,
          forceReplace: true, // ✅ RETRY WITH TRUE
        );
      }
      return; // ✅ EARLY RETURN - DON'T PROCEED WITH SUCCESS LOGIC
    }
    
    // ✅ SUCCESS HANDLING (EXISTING LOGIC)
    if (response.addedItems.isNotEmpty && state.dailyMealData != null) {
      final updatedSelectedItems = Map<String, List<MealItem>>.from(state.dailyMealData!.selectedMealItems);
      updatedSelectedItems[meal]?.addAll(response.addedItems);
      
      final updatedMealData = DailyMealData(
        date: state.dailyMealData!.date,
        mealRecommendations: state.dailyMealData!.mealRecommendations,
        selectedMealItems: updatedSelectedItems,
      );
      
      state = state.copyWith(
        isAddingFood: false,
        dailyMealData: updatedMealData,
      );
    }
    
    // ✅ SHOW SUCCESS MESSAGE
    if (context.mounted) {
      String message = response.message;
      
      if (response.skippedItems.isNotEmpty) {
        message += '\n\nSkipped items:';
        for (var skipped in response.skippedItems) {
          message += '\n• Item ${skipped['item_id']}: ${skipped['reason']}';
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: response.addedItems.isNotEmpty ? AppColors.kGreen : AppColors.kOrange,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
  } catch (e) {
    state = state.copyWith(isAddingFood: false);
    print('Error adding food to meal: $e');
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.kRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// ✅ NEW METHOD FOR GYM CONFLICT CONFIRMATION DIALOG
Future<bool> _showGymConflictDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // ✅ FORCE USER TO CHOOSE
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColors.kOrange,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Replace Gym Items?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'You already have items in Gym tab. If you continue, Gym items will be removed.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          // ✅ CANCEL BUTTON
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false); // ✅ RETURN FALSE
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // ✅ CONTINUE BUTTON
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true); // ✅ RETURN TRUE
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  ) ?? false; // ✅ DEFAULT TO FALSE IF DIALOG IS DISMISSED
}


  // Get user meal items method
  Future<List<AddedMealItem>> getUserMealItems({
    required String userId,
    required String meal,
  }) async {
    try {
      print('=== CONTROLLER: Getting user meal items ===');
      print('User ID: $userId, Meal: $meal');
      
      final response = await _bodyIqRepo.getUserMealItems(
        userId: userId,
        meal: meal,
      );
      
      print('=== CONTROLLER: Raw response ===');
      print('Response: $response');
      
      // Parse the response
      if (response['status'] == 'success' && response['data'] != null) {
        final items = (response['data'] as List<dynamic>?)
            ?.map((item) => AddedMealItem.fromJson(item))
            .toList() ?? [];
        
        print('=== CONTROLLER: Parsed items ===');
        print('Items count: ${items.length}');
        for (var item in items) {
          print('- ${item.itemName} (${item.calories}kcal)');
        }
        
        return items;
      }
      
      return [];
    } catch (e) {
      print('=== CONTROLLER: Error ===');
      print('Error getting user meal items: $e');
      return [];
    }
  }
  Future<void> saveSingleMealTime({
  required String userId,
  required String day,
  required String meal,
  required String time,
}) async {
  try {
    print('=== BODY IQ CONTROLLER: SAVING MEAL TIME ===');
    
    final requestData = {
      'user_id': int.parse(userId),
      'day': day,
      'meal': meal,
      'time': time,
    };

    print('Request Data: $requestData');

    final response = await _bodyIqRepo.saveSingleMealTime(data: requestData);
    
    print('=== MEAL TIME SAVED SUCCESSFULLY ===');
    print('Response: ${response.data}');
    
  } catch (e) {
    print('=== ERROR IN CONTROLLER: SAVING MEAL TIME ===');
    print('Error: $e');
    throw Exception('Failed to save meal time: $e');
  }
}
Future<void> deleteFoodItemsFromMeal({
  required String userId,
  required String day,
  required String meal,
  required List<int> itemIds,
}) async {
  try {
    print('=== CONTROLLER: DELETING FOOD ITEMS ===');
    print('User ID: $userId');
    print('Day: $day');
    print('Meal: $meal');
    print('Item IDs: $itemIds');

    final requestData = {
      'user_id': int.parse(userId),
      'day': day,
      'meal': meal,
      'item_ids': itemIds,
    };

    final response = await _bodyIqRepo.deleteFoodItemToMeal(data: requestData);
    
    print('=== CONTROLLER: DELETE SUCCESS ===');
    print('Response: ${response.data}');
    
  } catch (e) {
    print('=== CONTROLLER: DELETE ERROR ===');
    print('Error: $e');
    throw Exception('Failed to delete food items: $e');
  }
}


  // ───────────────────────────────────────────────
  // Navigation
  void navigateToAssessment(BuildContext context) {
    resetApp();
    NavigationWidget.commonNavigation(context: context, route: AppRoutesConstants.assessmentRoute);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void prevStep() {
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void resetApp() {
    state = BodyIqEntity.initial();
  }

  // ───────────────────────────────────────────────
  // User Data / Scoring

  // Oninit Function
  onInitFn({required String screenType, required ProfileData profile}) {
    clearUserProfileData();
    autoFetchUserProfile(profile: profile, screenType: screenType);
  }

  onInitDoshaReco(BuildContext context) {
     // ✅ PREVENT DUPLICATE CALLS
  if (_hasDoshaRecoLoaded) return;
  
  _hasDoshaRecoLoaded = true; // ✅ SET FLAG
    getDoshaRecoDiet(context);
    getDoshaRecoMeditation(context);
    getDoshaRecoExercise(context);
  }

  onInitRecoProduct(BuildContext context) {
    getRecoProducts(context);
  }

  // Api Function for inserting user profile
  Future<void> insertUserProfile(BuildContext context, {required String screenType}) async {
    try {
      state = state.copyWith(
        isUserInfoLoading: true,
      );
      await _bodyIqRepo.inserUserInfo(data: {
        "user_id": prefs.getString("userId"),
        "age": formatter.checkValue(state.ageController.text),
        "gender": formatter.checkValue(state.genderController.text),
        "height":
            state.heightController.text.isEmpty ? 0 : double.parse(formatter.checkValue(state.heightController.text)),
        "weight":
            state.weightController.text.isEmpty ? 0 : double.parse(formatter.checkValue(state.weightController.text)),
        "primary_goal": formatter.checkValue(state.selectedGoal),
        "ethnicity": formatter.checkValue(state.ethnicityController.text),
        "family_history_obesity": state.selectedHistory.contains("Obesity") ? 1 : 0,
        "family_history_diabetes": state.selectedHistory.contains("Diabetes") ? 1 : 0,
        "family_history_thyroid": state.selectedHistory.contains("Thyroid") ? 1 : 0,
        "family_history_pcos": state.selectedHistory.contains("PCOS") ? 1 : 0,
        "phoneNumber": formatter.checkValue(state.phoneNumberController.text),
      }).then(
        (value) {
          state = state.copyWith(
            isUserInfoLoading: false,
          );
          if (value != null) {
            log("User Update succes");

            showCustomPopup(
              context,
              title: value["status"],
              message: value["message"],
              iconData: value['status'] == "success" ? Icons.check : Icons.info_outline,
              okButtonText: 'Ok',
              onOkPressed: () {
                NavigationWidget.commonNavigatioPop(context: context);
                if (screenType == "BodyIQ") {
                  if (value['status'] == "success") {
                    nextStep();
                  } else {
                    log("Its an error::");
                  }
                } else {
                  NavigationWidget.commonNavigation(context: context, route: AppRoutesConstants.fitnessGoal);
                }
              },
              cancelButtonText: '',
              onCancelPressed: null,
            );
          }
        },
      );
    } on DioException catch (e) {
      log("Error messge of user : ${e.message}");
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
        isUserInfoLoading: false,
      );
    }
  }

  void autoFetchUserProfile({
    required ProfileData profile,
    required String screenType,
  }) {
    state = state.copyWith(
      nameController: TextEditingController(text: formatter.checkValue(profile.name)),
      ageController: TextEditingController(text: formatter.checkValue(profile.age)),
      genderController: TextEditingController(text: formatter.checkValue(profile.gender)),
      heightController: TextEditingController(text: formatter.checkValue(profile.height)),
      weightController: TextEditingController(text: formatter.checkValue(profile.weight)),
      phoneNumberController: TextEditingController(text: formatter.checkValue("${profile.phonecode}${profile.mobile}")),
    );
    validateUserProfile(screenType: screenType);
  }

  void updateUserData(Map<String, dynamic> data) {
    final updatedUserData = Map<String, dynamic>.from(state.userData)..addAll(data);
    state = state.copyWith(userData: updatedUserData);
  }

  void updateDoshaScore(String dosha) {
    final updatedScores = Map<String, int>.from(state.doshaScores);
    updatedScores[dosha] = (updatedScores[dosha] ?? 0) + 1;

    state = state.copyWith(doshaScores: updatedScores, currentDoshaQuestion: state.currentDoshaQuestion + 1);
  }

  void updateLifestyleScore(int score) {
    state = state.copyWith(
      lifestyleScore: state.lifestyleScore + score,
      currentLifestyleQuestion: state.currentLifestyleQuestion + 1,
    );
  }

  void updateRiskScore(bool isYes) {
    state = state.copyWith(
      riskScore: state.riskScore + (isYes ? 1 : 0),
      currentRiskQuestion: state.currentRiskQuestion + 1,
    );
  }

  void onPrimaryGoalOnTap({required String value}) {
    state = state.copyWith(
      selectedGoal: value,
    );
    validateUserProfile(screenType: "BodyIQ");
  }

  void onFamilyHistoryOnTap({required bool value, required String history}) {
    final updatedHistory = {...state.selectedHistory};
    if (value) {
      updatedHistory.add(history);
    } else {
      updatedHistory.remove(history);
    }
    state = state.copyWith(selectedHistory: updatedHistory);
    validateUserProfile(screenType: "BodyIQ");
  }

  void commonDropDownChange({required bool isGender, required String value, required String screenType}) {
    if (isGender) {
      state = state.copyWith(
        genderController: TextEditingController(text: value),
      );
    } else {
      state = state.copyWith(
        ethnicityController: TextEditingController(text: value),
      );
    }
    if (screenType == "BodyIQ") {
      validateUserProfile(screenType: "BodyIQ");
    } else {
      validateUserProfile(screenType: "Gym");
    }
  }

  void validateUserProfile({required String screenType}) {
    final bool isValid;
    if (screenType == "BodyIQ") {
      isValid = state.nameController.text.trim().isNotEmpty &&
          state.ageController.text.trim().isNotEmpty &&
          state.genderController.text != "Select gender" &&
          state.ethnicityController.text != "Select ethnicity" &&
          state.heightController.text.trim().isNotEmpty &&
          state.weightController.text.trim().isNotEmpty &&
          state.selectedGoal.isNotEmpty;
    } else {
      isValid = state.nameController.text.trim().isNotEmpty &&
          state.ageController.text.trim().isNotEmpty &&
          state.phoneNumberController.text.trim().isNotEmpty &&
          state.genderController.text != "Select gender";
    }
    state = state.copyWith(isUserProfileValid: isValid);
  }

  void clearUserProfileData() {
    state.nameController.clear();
    state.ageController.clear();
    state.phoneNumberController.clear();
    state.heightController.clear();
    state.weightController.clear();
    state = state.copyWith(
        selectedGoal: '',
        selectedHistory: <String>{},
        genderController: TextEditingController(text: 'Select gender'),
        ethnicityController: TextEditingController(text: 'Select ethnicity'));
  }

  // ───────────────────────────────────────────────
  // Dosha Quiz Logic

  // Api Function for inserting dosha/lifestyle quiz
  Future<void> insertDoshaLifestyleQuiz(BuildContext context, {required String screenType}) async {
    try {
      state = state.copyWith(
        isDoshaLoading: true,
      );
      await _bodyIqRepo.insertDoshaLifestyle(screenType: screenType, data: {
        "user_id": prefs.getString("userId"),
        "responses": screenType == "Dosha"
            ? state.selectedPositions.entries.map((entry) {
                return {
                  "question_id": entry.key.toString(),
                  "option_id": entry.value.toString(),
                };
              }).toList()
            : state.selectedLifeStylePositions.entries.map((entry) {
                return {
                  "question_id": entry.key.toString(),
                  "option_id": entry.value.toString(),
                };
              }).toList()
      }).then(
        (value) {
          state = state.copyWith(
            isDoshaLoading: false,
          );
          if (value != null) {
            log("Dosha Quiz Inserted Success");
            showCustomPopup(
              context,
              title: value["status"],
              message: value["message"],
              iconData: value['status'] == "success" ? Icons.check : Icons.info_outline,
              okButtonText: 'Ok',
              onOkPressed: () {
                NavigationWidget.commonNavigatioPop(context: context);
                if (value['status'] == "success") {
                  nextStep();
                } else {
                  log("Its an error::");
                }
              },
              cancelButtonText: '',
              onCancelPressed: null,
            );
          }
        },
      );
    } on DioException catch (e) {
      log("Error messge of dosha/lifestyle : ${e.message}");
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
        isDoshaLoading: false,
      );
    }
  }

  // Api Function for get dosha result profile
// Api Function for get dosha result profile
Future<void> getDoshaResult(BuildContext context) async {
  // ✅ PREVENT DUPLICATE CALLS
  if (_hasDoshaResultLoaded) return;
  
  try {
    _hasDoshaResultLoaded = true; // ✅ SET FLAG
    state = state.copyWith(isDoshaResultLoading: true);
    
    await _bodyIqRepo.getDoshaResultProfile(data: {
      "user_id": prefs.getString("userId"),
    }).then((value) {
      log("Dosha Result success");
      state = state.copyWith(
        isDoshaResultLoading: false,
        getDoshaResultModel: value,
      );
    });
  } on DioException catch (e) {
    _hasDoshaResultLoaded = false; // ✅ RESET ON ERROR
    log("Error message of user : ${e.message}");
    showCustomPopup(
      context,
      title: "Something went wrong!",
      message: e.message.toString(),
      iconData: Icons.info_outline,
      okButtonText: 'Ok',
      cancelButtonText: '',
      onCancelPressed: null,
    );
    state = state.copyWith(isDoshaResultLoading: false);
  }
}


  // Api Function for get dosha diet recommendation
  Future<void> getDoshaRecoDiet(BuildContext context) async {
    try {
      state = state.copyWith(
        isDoshaDietLoading: true,
      );
      await _bodyIqRepo.getDoshaDiet(data: {
        "dosha": state.getDoshaResultModel.dominantDosha,
      }).then(
        (value) {
          log("Dosha Reco diet succes");
          state = state.copyWith(
            isDoshaDietLoading: false,
            getDoshaRecoDietModel: value,
          );
        },
      );
    } on DioException catch (e) {
      log("Error messge of dosha diet : ${e.message}");
      state = state.copyWith(
        isDoshaDietLoading: false,
      );
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

  // Api Function for get dosha meditation recommendation
  Future<void> getDoshaRecoMeditation(BuildContext context) async {
    try {
      state = state.copyWith(
        isDoshaMeditationLoading: true,
      );
      await _bodyIqRepo.getDoshaMeditation(data: {
        "dosha": state.getDoshaResultModel.dominantDosha,
      }).then(
        (value) {
          log("Dosha Reco meditation succes");
          state = state.copyWith(
            isDoshaMeditationLoading: false,
            getDoshaRecoMeditationModel: value,
          );
        },
      );
    } on DioException catch (e) {
      log("Error messge of dosha meditation : ${e.message}");
      state = state.copyWith(
        isDoshaMeditationLoading: false,
      );
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

  // Api Function for get dosha exercise recommendation
  Future<void> getDoshaRecoExercise(BuildContext context) async {
    try {
      state = state.copyWith(
        isDoshaExerciseLoading: true,
      );
      await _bodyIqRepo.getDoshaExercise(data: {
        "dosha": state.getDoshaResultModel.dominantDosha,
      }).then(
        (value) {
          log("Dosha Reco exercise succes");
          state = state.copyWith(
            isDoshaExerciseLoading: false,
            getDoshaRecoExerciseModel: value,
          );
        },
      );
    } on DioException catch (e) {
      log("Error messge of dosha reco exercise : ${e.message}");
      state = state.copyWith(
        isDoshaExerciseLoading: false,
      );
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

  Future<void> selectDoshaOption({
    required String selectedOption,
    required VoidCallback onComplete,
  }) async {
    final answers = Map<int, String>.from(state.selectedAnswers);
    answers[state.currentDoshaQuestion] = selectedOption;

    state = state.copyWith(selectedAnswers: answers);

    final Map<int, int> updatedPositions = {};
    int globalIndex = 1;

    for (int qIndex = 0; qIndex < state.doshaOptions.length; qIndex++) {
      final int questionNumberOneBased = qIndex + 1;
      final options = state.doshaOptions[qIndex];

      for (int i = 0; i < options.length; i++) {
        if (answers[qIndex] == options[i]) {
          updatedPositions[questionNumberOneBased] = globalIndex;
        }
        globalIndex++;
      }
    }

    state = state.copyWith(
      selectedPositions: updatedPositions,
    );

    log("Selected answers response: ${state.selectedAnswers}");
    log("Selected global positions: ${state.selectedPositions}");

    await Future.delayed(const Duration(milliseconds: 400));

    if (state.currentDoshaQuestion < state.doshaQuestions.length - 1) {
      state = state.copyWith(currentDoshaQuestion: state.currentDoshaQuestion + 1);
    } else {
      onComplete();
    }
  }

  String get dominantDosha {
    final maxEntry = state.doshaScores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return maxEntry.key;
  }

  double get progressPercentageDosha => (state.currentDoshaQuestion + 1) / state.doshaQuestions.length;

  // ───────────────────────────────────────────────
  // Lifestyle Quiz Logic

// Api Function for get lifestyle result profile
Future<void> getLifeStyleResultFn(BuildContext context) async {
  // ✅ PREVENT DUPLICATE CALLS
  if (_hasLifestyleResultLoaded) return;
  
  try {
    _hasLifestyleResultLoaded = true; // ✅ SET FLAG
    state = state.copyWith(isLifeStyleResultLoading: true);
    
    await _bodyIqRepo.getLifeStyleResult(data: {
      "user_id": prefs.getString("userId"),
    }).then((value) {
      log("Lifestyle Result success");
      state = state.copyWith(
        isLifeStyleResultLoading: false,
        getLifeStyleResultModel: value,
      );
    });
  } on DioException catch (e) {
    _hasLifestyleResultLoaded = false; // ✅ RESET ON ERROR
    log("Error message of user : ${e.message}");
    showCustomPopup(
      context,
      title: "Something went wrong!",
      message: e.message.toString(),
      iconData: Icons.info_outline,
      okButtonText: 'Ok',
      cancelButtonText: '',
      onCancelPressed: null,
    );
    state = state.copyWith(isLifeStyleResultLoading: false);
  }
}


  Future<void> selectLifestyleOption({required String selectedOption, required VoidCallback onComplete}) async {
    final answers = Map<int, String>.from(state.selectedLifeStyleAnswers);
    answers[state.currentLifestyleQuestion] = selectedOption;

    state = state.copyWith(selectedLifeStyleAnswers: answers);
    final Map<int, int> updatedPositions = {};
    int globalIndex = 1;

    for (int qIndex = 0; qIndex < state.lifeStyleOptions.length; qIndex++) {
      final int questionNumberOneBased = qIndex + 1;
      final options = state.lifeStyleOptions[qIndex];

      for (int i = 0; i < options.length; i++) {
        if (answers[qIndex] == options[i]) {
          updatedPositions[questionNumberOneBased] = globalIndex;
        }
        globalIndex++;
      }
    }

    state = state.copyWith(
      selectedLifeStylePositions: updatedPositions,
    );

    log("Selected answers response: ${state.selectedAnswers}");
    log("Selected global positions: ${state.selectedLifeStylePositions}");
    // Delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 400));

    if (state.currentLifestyleQuestion < state.lifeStyleQuestions.length - 1) {
      state = state.copyWith(currentLifestyleQuestion: state.currentLifestyleQuestion + 1);
    } else {
      onComplete();
    }
  }

  double get progressPercentageLife => (state.currentLifestyleQuestion + 1) / state.lifeStyleQuestions.length;

  // ───────────────────────────────────────────────
  // Health Risk Quiz Logic

  // Api Function for inserting dosha/lifestyle quiz
  Future<void> insertHealthRiskQuiz(BuildContext context) async {
    try {
      state = state.copyWith(
        isHealthRiskLoading: true,
      );

      await _bodyIqRepo.insertHealthRisk(data: {
        "user_id": prefs.getString("userId"),
        "responses": state.selectedHealthRiskAnswers.map(
          (key, value) => MapEntry("q${key + 1}", value),
        ),
      }).then(
        (value) {
          state = state.copyWith(
            isHealthRiskLoading: false,
          );
          if (value != null) {
            log("Health Quiz Inserted Success");
            prefs.setString("score", value["score"].toString());
            prefs.setString("risk_level", value["risk_level"].toString());

            showCustomPopup(
              context,
              title: value["status"],
              message: value["message"],
              iconData: value['status'] == "success" ? Icons.check : Icons.info_outline,
              okButtonText: 'Ok',
              onOkPressed: () {
                NavigationWidget.commonNavigatioPop(context: context);
                if (value['status'] == "success") {
                  context.read<ProfileBloc>().add(ChangeTabIndex(3));
                  CustomSmoothNavigator.pushReplacement(context, MainScreen());
                } else {
                  log("Its an error::");
                }
              },
              cancelButtonText: '',
              onCancelPressed: null,
            );
          }
        },
      );
    } on DioException catch (e) {
      log("Error messge of health : ${e.message}");
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
        isHealthRiskLoading: false,
      );
    }
  }

  Future<void> selectHealthRiskOption({required String selectedOption, required VoidCallback onComplete}) async {
    final answers = Map<int, String>.from(state.selectedHealthRiskAnswers);
    answers[state.currentRiskQuestion] = selectedOption;

    state = state.copyWith(selectedHealthRiskAnswers: answers);
    // Delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 400));

    if (state.currentRiskQuestion < state.lifeStyleQuestions.length - 1) {
      state = state.copyWith(currentRiskQuestion: state.currentRiskQuestion + 1);
    } else {
      onComplete();
    }
  }

  // ───────────────────────────────────────────────
  // Products
// Api Function for get recommendation products
Future<void> getRecoProducts(BuildContext context) async {
  // ✅ PREVENT DUPLICATE CALLS
  if (_hasRecoProductsLoaded) return;
  
  try {
    _hasRecoProductsLoaded = true; // ✅ SET FLAG
    state = state.copyWith(isRecoProductsLoading: true);
    
    await _bodyIqRepo.getRecoProduct(data: {
      "dosha": state.getDoshaResultModel.dominantDosha,
    }).then((value) {
      log("Recommendation product");
      state = state.copyWith(
        isRecoProductsLoading: false,
        getRecoProductModel: value,
      );
    });
  } on DioException catch (e) {
    _hasRecoProductsLoaded = false; // ✅ RESET ON ERROR
    log("Error message of products : ${e.message}");
    state = state.copyWith(isRecoProductsLoading: false);
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


  // ✅ FIXED: Api Function for getting products by partner - removed hardcoded value
  Future<void> getProductsByPartner(BuildContext context) async {
    try {
      state = state.copyWith(
        isProductsByPartnerLoading: true,
      );
      await _bodyIqRepo.getRecoProductPartner(data: {
        "user_id": prefs.getString("userId"),
        "product_sub_category_id": formatter.checkValue(prefs.getString("subCategoryId")), // ✅ FIXED: Dynamic value
      }).then(
        (value) {
          log("Recommendation product");
          state = state.copyWith(
            isProductsByPartnerLoading: false,
            getProductByPartnerModel: value,
          );
        },
      );
    } on DioException catch (e) {
      log("Error messge of products by partner : ${e.message}");
      state = state.copyWith(
        isProductsByPartnerLoading: false,
      );
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

  onProductDetailsTap(
    BuildContext context, {
    required Product? product,
  }) {
    prefs.setString(
      "subCategoryId",
      formatter.checkValue(
        product?.productSubCategoryId,
      ),
    );
    NavigationWidget.commonNavigation(
      context: context,
      route: AppRoutesConstants.productDetailsRoute,
    );
  }

  // ───────────────────────────────────────────────
}
