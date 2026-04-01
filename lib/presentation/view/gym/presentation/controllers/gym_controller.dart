import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/app/widgets/common_dialogs/common_dialogs.dart';
import 'package:orka_sports/app/widgets/common_formatter/common_formatter.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_gym_buddy.dart';
import 'package:orka_sports/presentation/view/gym/data/models/gym_details_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/meal_plan_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/search_gym_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';
// ✅ ADDED MISSING IMPORT
import 'package:orka_sports/presentation/view/gym/data/models/gym_food_models.dart';
import 'package:orka_sports/presentation/view/gym/data/models/target_calories_model.dart';
import 'package:orka_sports/presentation/view/gym/data/repositories/gym_repo_impl.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/domain/repositories/gym_repo.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_diet_tracking_screen.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/gym_coaches/coaches_details.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/presentation/pages/gym_scheduler/gym_scheduler.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GymController extends StateNotifier<GymEntity> {
  GymController() : super(GymEntity.initial());

  final GymRepo _gymRepo = GymRepoImpl();
  final SharedPreferences prefs = GetItService.getIt<SharedPreferences>();
  final CommonFormatter formatter = CommonFormatter();

  void resetGym() {
    state = GymEntity.initial();
  }

  void toInfoScreenGym(BuildContext context) {
    resetGym();
    NavigationWidget.commonNavigation(context: context, route: AppRoutesConstants.basicGymInfo);
  }

  Future<void> getGoalsPref(BuildContext context) async {
    try {
      state = state.copyWith(isPreferrencesLoading: true);
      await _gymRepo.getGymGoalsRepo(data: {
        "user_id": prefs.getString("userId"),
        "fitness_goal": formatter.checkValue(state.fitnessController.text),
        "experience_level": formatter.checkValue(state.expController.text),
        "communication_style": formatter.checkValue(state.communicationController.text),
        "gender_preference_for_buddy": formatter.checkValue(state.buddyGenderController.text),
      }).then(
        (value) {
          log("API Call Success");
          showCustomPopup(
            context,
            title: formatter.checkValue(value.status),
            message: formatter.checkValue(value.message),
            iconData: value.status == "success" ? Icons.check : Icons.info_outline,
            okButtonText: 'Ok',
            onOkPressed: () {
              NavigationWidget.commonNavigatioPop(context: context);
              if (value.status == "success") {
                NavigationWidget.commonNavigation(
                  context: context,
                  route: AppRoutesConstants.gymSelection,
                );
              } else {
                log("Its an error::");
              }
            },
            cancelButtonText: '',
            onCancelPressed: null,
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
      state = state.copyWith(isPreferrencesLoading: false);
    }
  }

  void toggleGridSelection(SelectableTileItem item) {
    final updatedItems = [
      ...state.selectedItems.where((i) => i.category != item.category),
      item,
    ];

    switch (item.category) {
      case "Fitness goal":
        state.fitnessController.text = item.title;
        break;
      case "Experience Level":
        state.expController.text = item.title;
        break;
      case "Communication Style":
        state.communicationController.text = item.title;
        break;
      case "Buddy Gender Preference":
        state.buddyGenderController.text = item.title;
        break;
      case "Buddy Status":
        state.buddyStatusController.text = item.title;
        break;
    }

    state = state.copyWith(selectedItems: updatedItems);
    log("Controller values after selection:");
    log("Fitness Goal: ${state.fitnessController.text}");
    log("Experience Level: ${state.expController.text}");
    log("Communication Style: ${state.communicationController.text}");
    log("Buddy Gender Preference: ${state.buddyGenderController.text}");
    log("Buddy Status: ${state.buddyStatusController.text}");
  }

  void clearGridSelection() {
    state = state.copyWith(selectedItems: []);
    state.fitnessController.clear();
    state.expController.clear();
    state.communicationController.clear();
    state.buddyGenderController.clear();
    state.buddyStatusController.clear();
  }

  Future<void> searchGymFn(BuildContext context) async {
    try {
      state = state.copyWith(isSearchGymLoading: true);
      final value = await _gymRepo.searchGymRepo(data: {
        "user_id": prefs.getString("userId"),
        "name": formatGymName(formatter.checkValue(state.searchGymController.text)),
      });
      if (value.status == "success") {
        log("Successfully got the searched gym $value");
        state = state.copyWith(searchGymList: value);
      }
      else {
        // API responded with status = error (e.g. no gym within 5 km)
        log("Gym search error response: ${value.message}");
        state = state.copyWith(searchGymList: value);
        showCustomPopup(
          context,
          title: "No gyms found",
          message: formatter.checkValue(value.message),
          iconData: Icons.info_outline,
          okButtonText: 'Ok',
          cancelButtonText: '',
          onCancelPressed: null,
        );
      }

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
      state = state.copyWith(isSearchGymLoading: false);
    }
  }

  Future<void> getNearByGyms(BuildContext context, {required String type}) async {
    try {
      state = state.copyWith(isNearGymLoading: true);

      Map<String, dynamic> requestData;
      Future<dynamic> futureCall;

      if (type == "subIndustry") {
        requestData = {
          "user_id": prefs.getString("userId"),
          "sub_industry": prefs.getString("subIndustryId"),
        };
        futureCall = _gymRepo.getNearByGymByTypeRepo(data: requestData);
      } else {
        requestData = {
          "user_id": prefs.getString("userId"),
        };
        futureCall = _gymRepo.getNearGymRepo(data: requestData);
      }

      await futureCall.then((response) {
        log("Success [$type] gyms: $response");
        state = state.copyWith(
          getNearGymsList: response,
        );
      });
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
      state = state.copyWith(isNearGymLoading: false);
    }
  }

  Future<void> getGymDetails(BuildContext context) async {
    getCoaches(context);
    try {
      state = state.copyWith(
        isGymDetailsLoading: true,
      );
      await _gymRepo.getGymDetailsRepo(data: {
        "partner_id": formatter.checkValue(prefs.getString("partnerId")),
      }).then(
        (value) {
          log("Success gym details $value");
          state = state.copyWith(
            getGymDetailsList: value,
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
        isGymDetailsLoading: false,
      );
    }
  }

Future<void> checkGymVerificationStatus() async {
  try {
    final userId = prefs.getString("userId");
    if (userId == null) return;

    final response = await _gymRepo.getUserGymMembershipRepo(data: {
      "user_id": int.parse(userId),
    });

    log("Server verification check response: $response");

    if (response['status'] == 'success' && response['has_membership'] == true) {
      await prefs.setBool("isGymCodeVerified", true);

      if (response['data']['partner_id'] != null) {
        await prefs.setString("partnerId", response['data']['partner_id'].toString());
      }
      
      state = state.copyWith(isGymCodeVerified: true);
      log("✅ User gym verification restored from server");
    } else {
      await prefs.setBool("isGymCodeVerified", false);
      state = state.copyWith(isGymCodeVerified: false);
      log("❌ User is not verified on server");
    }
  } catch (e) {
    log("⚠️ Server check failed, using local storage: $e");
    final localVerification = prefs.getBool("isGymCodeVerified") ?? false;
    state = state.copyWith(isGymCodeVerified: localVerification);
  }
}

  void setGymCodeVerified(bool isVerified) {
    state = state.copyWith(isGymCodeVerified: isVerified);
  }

  Future<void> getSubIndustry(BuildContext context) async {
    try {
      state = state.copyWith(
        isSubIndustryLoading: true,
      );
      await _gymRepo.getSubIndustryRepo(data: {
        "categoryId": "21",
      }).then(
        (value) {
          log("Success near sub industry $value");
          state = state.copyWith(
            getSubIndustryList: value,
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
        isSubIndustryLoading: false,
      );
    }
  }

  Future<void> requestGymPartner(BuildContext context) async {
    try {
      state = state.copyWith(isRequestGymLoading: true);

      final value = await _gymRepo.requestGymPartnerRepo(data: {
        "user_id": formatter.checkValue(prefs.getString("userId")),
        "partner_id": formatter.checkValue(prefs.getString("partnerId")),
      });

      final status = value['status'].toString();
      final message = value['message'] ?? "No message";

      log("Request Gym Response: $value");
      showCustomSnackbar(
        context,
        message,
        isError: status == "error" ? true : false,
      );
      sendGymDetailsViaWhatsApp(context);
    } catch (e) {
      log("Exception in requestGymPartner: $e");
      showCustomSnackbar(
        context,
        "Something went wrong!\n${e.toString()}",
        isError: true,
      );
    } finally {
      state = state.copyWith(isRequestGymLoading: false);
    }
  }

  Future<void> getCoaches(BuildContext context) async {
    try {
      state = state.copyWith(
        isCoachesListLoading: true,
      );
      await _gymRepo.getCoachesListRepo(data: {
        "partner_id": formatter.checkValue(prefs.getString("partnerId")),
      }).then(
        (value) {
          log("Success coaches list $value");
          state = state.copyWith(
            getCoachesList: value,
          );
        },
      );
    } catch (e) {
      log("coach list error : ${e.toString()}");
    } finally {
      state = state.copyWith(
        isCoachesListLoading: false,
      );
    }
  }

  Future<void> getCoachesDetails(BuildContext context) async {
    try {
      state = state.copyWith(
        isCoachesDetailsLoading: true,
      );
      await _gymRepo.getCoachesDetailsRepo(data: {
        "coach_id": formatter.checkValue(prefs.getString("coachId")),
      }).then(
        (value) {
          log("Success coaches details $value");
          state = state.copyWith(
            getCoachesDetails: value,
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
        isCoachesDetailsLoading: false,
      );
    }
  }

  Future<GymMealRecommendationsResponse> getGymFoodItemsByMeal({
    required String userId,
    required String meal,
    required int foodType,
  }) async {
    try {
      state = state.copyWith(isGymFoodLoading: true);
      
      final response = await _gymRepo.getGymFoodItemsByMeal(
        userId: userId,
        meal: meal,
        foodType: foodType,
      );
      
      state = state.copyWith(isGymFoodLoading: false, currentGymRecommendations: response);
      return response;
    } catch (e) {
      state = state.copyWith(isGymFoodLoading: false);
      log("Error getting gym food items: $e");
      throw e;
    }
  }

Future<void> addSelectedGymFoodToMeal({
  required BuildContext context,
  required String userId,
  required String meal,
  required List<GymFoodRecommendation> selectedItems,
  required String day,
}) async {
  await _addGymFoodWithConflictHandling(
    context: context,
    userId: userId,
    meal: meal,
    selectedItems: selectedItems,
    day: day,
    forceReplace: false, // ✅ INITIAL CALL WITH FALSE
  );
}

// ✅ NEW PRIVATE METHOD TO HANDLE THE CONDITIONAL LOGIC
Future<void> _addGymFoodWithConflictHandling({
  required BuildContext context,
  required String userId,
  required String meal,
  required List<GymFoodRecommendation> selectedItems,
  required String day,
  required bool forceReplace,
}) async {
  try {
    state = state.copyWith(isGymFoodLoading: true);
    
    final itemIds = selectedItems.map((item) => int.parse(item.itemId)).toList();
    
    log('=== ADDING GYM FOOD ITEMS ===');
    log('User ID: $userId');
    log('Meal: $meal');
    log('Item IDs: $itemIds');
    log('Day: $day');
    log('Force Replace BodyIQ: $forceReplace');
    
    final response = await _gymRepo.addGymFoodItemToMeal(
      userId: userId,
      meal: meal,
      itemIds: itemIds,
      day: day,
      forceReplaceBodyIq: forceReplace,
    );
    
    log('=== ADD GYM FOOD RESPONSE ===');
    log('Response: $response');
    
    // ✅ MOVE CONFLICT CHECK TO THE BEGINNING - BEFORE SUCCESS PROCESSING
    if (!forceReplace && 
        (response['status'] == 'confirm' || response['require_confirmation'] == true)) {
      
      log('=== CONFLICT DETECTED - SHOWING DIALOG ===');
      state = state.copyWith(isGymFoodLoading: false);
      
      final shouldContinue = await _showBodyIqConflictDialog(context);
      
      if (shouldContinue) {
        await _addGymFoodWithConflictHandling(
          context: context,
          userId: userId,
          meal: meal,
          selectedItems: selectedItems,
          day: day,
          forceReplace: true,
        );
      }
      return; // ✅ EARLY RETURN - DON'T PROCESS AS SUCCESS
    }
    
    // ✅ ONLY PROCESS SUCCESS IF NOT A CONFLICT
    if (response['status'] == 'success') {
      final addedItems = response['added_items'] as List?;
      final skippedItems = response['skipped_items'] as List?;
      
      String message = 'Items processed successfully!';
      bool isError = false;
      
      if (skippedItems != null && skippedItems.isNotEmpty) {
        final skippedReasons = skippedItems.map((item) => 
          'Item ${item['item_id']}: ${item['reason']}'
        ).join('\n');
        
        message = 'Some items were skipped:\n$skippedReasons';
        isError = false;
      }
      
      showCustomSnackbar(
        context,
        message,
        isError: isError,
      );
      
      log("Gym food items processed successfully");
    } else {
      // ✅ ONLY THROW ERROR FOR ACTUAL ERRORS, NOT CONFLICTS
      throw Exception(response['message'] ?? 'Failed to add items');
    }
    
  } catch (e) {
    log("Error adding gym food items: $e");
    
    showCustomSnackbar(
      context,
      "Error adding items: $e",
      isError: true,
    );
    
    throw e;
  } finally {
    state = state.copyWith(isGymFoodLoading: false);
  }
}


// ✅ NEW METHOD FOR BODYIQ CONFLICT CONFIRMATION DIALOG
Future<bool> _showBodyIqConflictDialog(BuildContext context) async {
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
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Replace BodyIQ Items?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text(
          'You already have items in BodyIQ tab. If you continue, BodyIQ items will be removed.',
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
              backgroundColor: Colors.orange,
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

  // ✅ ADD THIS METHOD TO YOUR GYM CONTROLLER
Future<List<GymAddedMealItem>> getUserGymMealItems({
  required String userId,
  required String meal,
}) async {
  try {
    state = state.copyWith(isGymFoodLoading: true);
    
    final response = await _gymRepo.getUserGymMealItems(
      userId: userId,
      meal: meal,
    );
    
    state = state.copyWith(isGymFoodLoading: false);
    return response;
  } catch (e) {
    state = state.copyWith(isGymFoodLoading: false);
    log("Error getting user gym meal items: $e");
    return [];
  }
}
// Add this method to your GymController class
Future<TargetCaloriesResponse> getTargetCalories({
  required String userId,
}) async {
  try {
    return await _gymRepo.getTargetCalories(userId: userId);
  } catch (e) {
    throw Exception('Controller: Failed to fetch target calories: $e');
  }
}
// Add this method to your GymController class
Future<MealPlanResponse> generateMealPlanByCalories({
  required String userId,
}) async {
  try {
    print('=== GYM CONTROLLER: GENERATING MEAL PLAN ===');
    print('User ID: $userId');
    
    return await _gymRepo.generateMealPlanByCalories(userId: userId);
  } catch (e) {
    log('GymController.generateMealPlanByCalories error: $e');
    throw Exception('Controller: Failed to generate meal plan: $e');
  }
}
Future<void> saveSingleMealTime({
  required String userId,
  required String day,
  required String meal,
  required String time,
}) async {
  try {
    print('=== GYM CONTROLLER: SAVING MEAL TIME ===');
    
    final requestData = {
      'user_id': int.parse(userId),
      'day': day,
      'meal': meal,
      'time': time,
    };

    print('Request Data: $requestData');

    final response = await _gymRepo.saveSingleMealTime(data: requestData);
    
    print('=== GYM MEAL TIME SAVED SUCCESSFULLY ===');
    print('Response: ${response.data}');
    
  } catch (e) {
    print('=== ERROR IN GYM CONTROLLER: SAVING MEAL TIME ===');
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
    print('=== GYM CONTROLLER: DELETING FOOD ITEMS ===');
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

    final response = await _gymRepo.deleteFoodItemToMeal(data: requestData);
    
    print('=== GYM CONTROLLER: DELETE SUCCESS ===');
    print('Response: ${response.data}');
    
  } catch (e) {
    print('=== GYM CONTROLLER: DELETE ERROR ===');
    print('Error: $e');
    throw Exception('Failed to delete food items: $e');
  }
}



  void onShowAllCoaches() {
    state = state.copyWith(
      isShowAllCoaches: !state.isShowAllCoaches,
    );
  }

  void onCoachesDetailScreen(BuildContext context, {required String coachId}) {
    prefs.setString("coachId", coachId);
    getCoachesDetails(context);
    CustomSmoothNavigator.push(
      context,
      CoachDetailScreen(),
    );
  }

  void sendGymDetailsViaWhatsApp(BuildContext context) async {
    final data = state.getGymDetailsList.data;

    final phoneNumber = '${data?.phonecode ?? ''}${data?.mobile ?? ''}'.replaceAll(RegExp(r'[^\d+]'), '');

    final message = '''
🏋️ *${data?.name ?? "Gym Name"}*
📞 Phone: ${data?.phonecode ?? ""}${data?.mobile ?? ""}
📧 Email: ${data?.email ?? "Not Available"}

Check out this gym on Orka Sports! 💪

I want information about gym membership.
''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackbar(context, 'Could not open WhatsApp');
    }
  }

  String formatGymName(String input) {
    // Trim and split by spaces
    final words = input.trim().split(RegExp(r'\s+'));

    // Capitalize each word
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });

    return capitalizedWords.join(' ');
  }

  void onSelectedSubIndustryId(BuildContext context, {required String value}) {
    state = state.copyWith(
      selectedSubIndustryId: value,
    );
    if (value.isNotEmpty) {
      prefs.setString("subIndustryId", value);
      getNearByGyms(context, type: "subIndustry");
    }
  }

  void onGymDetailsOnTap(BuildContext context,
      {required String type, required String partnerId, required SearchGymData searchGym}) {
    prefs.setString(
      "partnerId",
      formatter.checkValue(partnerId),
    );
    prefs.setString(
      "gymType",
      formatter.checkValue(type),
    );
    if (type == "Near Gym") {
      NavigationWidget.commonNavigation(context: context, route: AppRoutesConstants.gymDetails);
      getGymDetails(context);
    } else {
      GymDetailsData(
        id: formatter.checkValue(searchGym.id),
        name: formatter.checkValue(searchGym.name),
        email: formatter.checkValue(searchGym.email),
        phonecode: formatter.checkValue(searchGym.phonecode),
        mobile: formatter.checkValue(searchGym.mobile),
        locationUrl: formatter.checkValue(searchGym.locationUrl),
        address: formatter.checkValue(searchGym.address),
        description: formatter.checkValue(searchGym.description),
        startTimeMonday: formatter.checkValue(searchGym.startTimeMonday),
        endTimeMonday: formatter.checkValue(searchGym.endTimeMonday),
        startTimeTuesday: formatter.checkValue(searchGym.startTimeTuesday),
        endTimeTuesday: formatter.checkValue(searchGym.endTimeTuesday),
        startTimeWednesday: formatter.checkValue(searchGym.startTimeWednesday),
        endTimeWednesday: formatter.checkValue(searchGym.endTimeWednesday),
        startTimeThursday: formatter.checkValue(searchGym.startTimeThursday),
        endTimeThursday: formatter.checkValue(searchGym.endTimeThursday),
        startTimeFriday: formatter.checkValue(searchGym.startTimeFriday),
        endTimeFriday: formatter.checkValue(searchGym.endTimeFriday),
        startTimeSaturday: formatter.checkValue(searchGym.startTimeSaturday),
        endTimeSaturday: formatter.checkValue(searchGym.endTimeSaturday),
        startTimeSunday: formatter.checkValue(searchGym.startTimeSunday),
        endTimeSunday: formatter.checkValue(searchGym.endTimeSunday),
        features: formatter.checkValue(searchGym.features),
        partnerImage: formatter.checkValue(searchGym.partnerImage),
      );
      NavigationWidget.commonNavigation(context: context, route: AppRoutesConstants.gymDetails);
    }
  }

  void selectMembershipOption(String option) {
    state = state.copyWith(
      selectedMembershipOption: option,
      selectedGymIndex: -1,
    );
  }

  void selectGymIndex(int index) {
    state = state.copyWith(selectedGymIndex: index);
  }

  void onSearchGymValidation() {
    if (state.searchGymController.text.isEmpty) {
      state = state.copyWith(
        isSearchFieldValid: false,
      );
    } else {
      state = state.copyWith(
        isSearchFieldValid: true,
      );
    }
  }

  void onVerifyCodeValid() {
    if (state.gymCodeController.text.isEmpty) {
      state = state.copyWith(
        isVerifyCode: false,
      );
    } else {
      state = state.copyWith(
        isVerifyCode: true,
      );
    }
    log("validate : ${state.isVerifyCode}");
  }

  onClearGymCode() {
    state.gymCodeController.clear();
    onVerifyCodeValid();
  }

  // Functions for gym buddy
  //----------------------------------------------------
  // Function to get gym buddy
  Future<void> getGymBuddy(BuildContext context) async {
    try {
      state = state.copyWith(
        isGymBuddyLoading: true,
      );
      await _gymRepo.getGymBuddyRepo(data: {
        "partner_id": formatter.checkValue(prefs.getString("partnerId")),
      }).then(
        (value) {
          log("Success near gym buddy $value");
          state = state.copyWith(
            getGymBuddyList: value,
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
        isGymBuddyLoading: false,
      );
    }
  }

  // Function to get gym buddy details
  Future<void> getGymBuddyDetails(BuildContext context) async {
    try {
      state = state.copyWith(
        isGymBuddyDetailsLoading: true,
      );
      await _gymRepo.getGymBuddyDetailsRepo(data: {
        "partner_id": formatter.checkValue(prefs.getString("partnerId")),
        "buddy_id": formatter.checkValue(prefs.getString("buddyId")),
      }).then(
        (value) {
          log("Success near gym buddy details $value");

          state = state.copyWith(
            getGymBuddyDetailsList: value,
            getBuddyDataList: getFilteredBuddyList(),
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
        isGymBuddyDetailsLoading: false,
      );
    }
  }

  // Function to request gym buddy
Future<void> requestGymBuddy(BuildContext context) async {
  try {
    // Set loading state
    state = state.copyWith(isRequestBuddyLoading: true);
    
    final prefs = await SharedPreferences.getInstance();
    final myUserId = prefs.getString("userId");
    final buddyUserId = state.getGymBuddyDetailsList.data?.profile?.userId;  // ✅ FIXED
    final buddyName = state.getGymBuddyDetailsList.data?.profile?.name;
    
    if (myUserId == null || buddyUserId == null) {
      throw Exception("Missing user information");
    }

    final response = await http.post(
      Uri.parse('https://fitfirst.online/Api/sendBuddyRequest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender_id': int.parse(myUserId),
        'receiver_id': int.parse(buddyUserId), // Parse since id is String
        'message': 'Hi $buddyName! I would like to be your gym buddy.',
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buddy request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(jsonResponse['message']);
      }
    } else {
      throw Exception('Failed to send request');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    state = state.copyWith(isRequestBuddyLoading: false);
  }
}



  // Function to verify gym code
// Update your existing verifyGymCode method to set verification state
Future<void> verifyGymCode(BuildContext context) async {
  try {
    state = state.copyWith(isVerifyCodeLoading: true);

    final value = await _gymRepo.verifyGymCodeRepo(data: {
      "user_id": formatter.checkValue(prefs.getString("userId")),
      "gym_code": formatter.checkValue(state.gymCodeController.text),
    });

    final status = value['status'].toString();
    final message = value['message'] ?? "No message";

    log("Gym Code Verification Response: $value");

    if (status == "success") {
      // ✅ SET VERIFICATION STATE
      await prefs.setBool("isGymCodeVerified", true);
      state = state.copyWith(isGymCodeVerified: true);
      
      // Store partner_id from response
      if (value['data'] != null && value['data']['partner_id'] != null) {
        await prefs.setString("partnerId", value['data']['partner_id'].toString());
      }

      showCustomPopup(
        context,
        title: "Success",
        message: message,
        iconData: Icons.check,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
        onOkPressed: () {
          NavigationWidget.commonNavigatioPop(context: context);
          NavigationWidget.commonNavigatioPop(context: context);
          ProviderScope.containerOf(context)
              .read(DiProviders.schedulerControllerProvider.notifier)
              .clearGymScheduleControllers();
          CustomSmoothNavigator.push(context, GymSchedulerScreen());
        },
      );
    } else {
      showCustomPopup(
        context,
        title: "Error",
        message: message,
        iconData: Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
      );
    }
  } catch (e) {
    log("Exception in verifyGymCode: $e");
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
    state = state.copyWith(isVerifyCodeLoading: false);
  }
}


  void onGymBuddyOnTap(BuildContext context, {required String partnerId}) {
    prefs.setString(
      "partnerId",
      formatter.checkValue(partnerId),
    );
    NavigationWidget.commonNavigation(context: context, route: AppRoutesConstants.gymBuddy);
    getGymBuddy(
      context,
    );
  }

  void onGymBuddyDetailsOnTap(BuildContext context, {required String buddyId}) {
    prefs.setString(
      "buddyId",
      formatter.checkValue(buddyId),
    );
    NavigationWidget.commonNavigation(context: context, route: AppRoutesConstants.gymBuddyDetails);
    getGymBuddyDetails(
      context,
    );
  }

  void updateExperienceFilter(String experience) {
    state = state.copyWith(selectedExperience: experience);
  }

  List<GymBuddyData>? getFilteredBuddyList() {
    if (state.selectedExperience == 'All') {
      return state.getGymBuddyList.data;
    }
    return state.getGymBuddyList.data?.where((buddy) => buddy.fitnessLevel == state.selectedExperience).toList();
  }
}
