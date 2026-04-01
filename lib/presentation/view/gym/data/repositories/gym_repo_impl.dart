import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:orka_sports/core/utils/error_handling.dart';
import 'package:orka_sports/presentation/view/gym/data/datasources/gym_services.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_coaches_details_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_coaches_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_gym_buddy.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_gym_buddy_details_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_gym_goals_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_near_gym_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_sub_industry_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/gym_details_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/meal_plan_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/search_gym_model.dart';
// ✅ ADD MISSING IMPORT
import 'package:orka_sports/presentation/view/gym/data/models/gym_food_models.dart';
import 'package:orka_sports/presentation/view/gym/data/models/target_calories_model.dart';
import 'package:orka_sports/presentation/view/gym/domain/repositories/gym_repo.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_diet_tracking_screen.dart';

class GymRepoImpl extends GymServices implements GymRepo {
  //Repo function for getting gym goals
  @override
  Future<GetGymGoalsModel> getGymGoalsRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getGymGoalsService(data: data);
      GetGymGoalsModel getGymGoalsRepo = GetGymGoalsModel.fromJson(response.data);
      return getGymGoalsRepo;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function for searching gym
  @override
  Future<SearchGymModel> searchGymRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await searchGymService(data: data);
      SearchGymModel searchGymModel = SearchGymModel.fromJson(response.data);
      return searchGymModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function for getting near gym
  @override
  Future<GetNearGymModel> getNearGymRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getNearGymService(data: data);
      GetNearGymModel getNearGymModel = GetNearGymModel.fromJson(response.data);
      return getNearGymModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to get gym details
  @override
  Future<GetGymDetailsModel> getGymDetailsRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getGymDetailsService(data: data);
      GetGymDetailsModel getGymDetailsModel = GetGymDetailsModel.fromJson(response.data);
      return getGymDetailsModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to get gym buddy
  @override
  Future<GetGymBuddyModel> getGymBuddyRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getGymBuddyService(data: data);
      GetGymBuddyModel getGymBuddyModel = GetGymBuddyModel.fromJson(response.data);
      return getGymBuddyModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to get gym buddy details
  @override
  Future<GetGymBuddyDetailsModel> getGymBuddyDetailsRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getGymBuddyDetailsService(data: data);
      GetGymBuddyDetailsModel getGymBuddyDetailsModel = GetGymBuddyDetailsModel.fromJson(response.data);
      return getGymBuddyDetailsModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to request gym buddy
  @override
  Future<dynamic> requestGymBuddyRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await requestGymBuddyService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to verify gym code
  @override
  Future<dynamic> verifyGymCodeRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await verifyGymCodeService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to get sub industry
  @override
  Future<GetSubIndustryModel> getSubIndustryRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getSubIndustryService(data: data);
      GetSubIndustryModel getSubIndustryModel = GetSubIndustryModel.fromJson(response.data);
      return getSubIndustryModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo funtion to get nearby gym by type (sub industry type)
  @override
  Future<GetNearGymModel> getNearByGymByTypeRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getNearByGymByTypeService(data: data);
      GetNearGymModel getNearGymModel = GetNearGymModel.fromJson(response.data);
      return getNearGymModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to request gym partner
  @override
  Future<dynamic> requestGymPartnerRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await requestGymPartnerService(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to get coaches list
  @override
  Future<GetCoachesListModel> getCoachesListRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getCoachesListService(data: data);
      GetCoachesListModel getCoachesListModel = GetCoachesListModel.fromJson(response.data);
      return getCoachesListModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  //Repo function to get coaches details
  @override
  Future<GetCoachesDetailsModel> getCoachesDetailsRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getCoachesDetailsService(data: data);
      GetCoachesDetailsModel getCoachesDetailsModel = GetCoachesDetailsModel.fromJson(response.data);
      return getCoachesDetailsModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }

  // ✅ CORRECTED GYM FOOD METHODS
  
  // Repo function to get gym food items by meal
  @override
  Future<GymMealRecommendationsResponse> getGymFoodItemsByMeal({
    required String userId,
    required String meal,
    required int foodType,
  }) async {
    try {
      final response = await getGymFoodItemsByMealService(data: {
        'user_id': int.parse(userId),
        'meal': meal,
        'food_type': foodType,
      });
      return GymMealRecommendationsResponse.fromJson(response.data);
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  // Repo function to add gym food items to meal
@override
Future<Map<String, dynamic>> addGymFoodItemToMeal({
  required String userId,
  required String meal,
  required List<int> itemIds,
  required String day,
  bool forceReplaceBodyIq = false,
}) async {
  try {
    final response = await addGymFoodItemToMealService(data: {
      'user_id': userId,
      'meal': meal,
      'item_id': itemIds,
      'day': day,
      'force_replace_bodyiq': forceReplaceBodyIq,
    });
    
    log('=== GYM REPO RESPONSE ===');
    log('Status Code: ${response.statusCode}');
    log('Response Data: ${response.data}');
    
    // ✅ RETURN RESPONSE DATA DIRECTLY (DON'T THROW ON SUCCESS)
    return response.data as Map<String, dynamic>;
  } catch (e) {
    log("error-- : $e");
    throw ErrorHandler.handleError(e);
  }
}


  // ✅ ADD TO GYM REPO IMPLEMENTATION
@override
Future<List<GymAddedMealItem>> getUserGymMealItems({
  required String userId,
  required String meal,
}) async {
  try {
    final requestData = {
      'user_id': int.parse(userId),
      'meal': meal,
    };

    print('=== FETCHING USER ITEMS REQUEST ===');
    print('Request Data: $requestData');
    
    final response = await getUserGymMealItemsService(data: requestData);
    
    print('=== FETCH RESPONSE ===');
    print('Response: ${response.data}');
    
    // ✅ HANDLE THE CORRECT API RESPONSE STRUCTURE
    if (response.data['status'] == 'success' && response.data['data'] != null) {
      final items = response.data['data'] as List; // ✅ Changed from 'items' to 'data'
      print('=== PARSING ${items.length} ITEMS ===');
      return items.map((item) => GymAddedMealItem.fromJson(item)).toList();
    } else {
      // API returned error or no data
      print('No items found for meal: $meal - ${response.data['message'] ?? 'Unknown error'}');
      return [];
    }
  } catch (e) {
    log("error-- : $e");
    return [];
  }
}
// ✅ CORRECTED METHOD - Fix the return type to match parent class
@override
Future<TargetCaloriesResponse> getTargetCalories({
  required String userId,
}) async {
  try {
    print('=== GYM REPO: FETCHING TARGET CALORIES ===');
    print('User ID: $userId');
    
    final response = await getTargetCaloriesService(data: {
      'user_id': int.parse(userId),
    });
    
    print('=== GYM REPO: TARGET CALORIES RESPONSE ===');
    print('Response: ${response.data}');
    
    TargetCaloriesResponse targetCaloriesResponse = TargetCaloriesResponse.fromJson(response.data);
    return targetCaloriesResponse;
  } catch (e) {
    log("error-- : $e");
    throw ErrorHandler.handleError(e);
  }
}
// Add this method to your GymRepoImpl class
@override
Future<MealPlanResponse> generateMealPlanByCalories({
  required String userId,
}) async {
  try {
    print('=== GYM REPO: GENERATING MEAL PLAN ===');
    print('User ID: $userId');
    
    final response = await generateMealPlanByCaloriesService(data: {
      'user_id': int.parse(userId),
    });
    
    print('=== GYM REPO: MEAL PLAN RESPONSE ===');
    print('Response: ${response.data}');
    
    MealPlanResponse mealPlanResponse = MealPlanResponse.fromJson(response.data);
    return mealPlanResponse;
  } catch (e) {
    log("error-- : $e");
    throw ErrorHandler.handleError(e);
  }
}
@override
Future<Response> saveSingleMealTime({required Map<String, dynamic> data}) async {
  return await saveSingleMealTimeService(data: data);
}
@override
Future<Response> deleteFoodItemToMeal({required Map<String, dynamic> data}) async {
  return await deleteFoodItemToMealService(data: data);
}
@override
Future<Map<String, dynamic>> getUserGymMembershipRepo({required Map<String, dynamic> data}) async {
  try {
    final response = await getUserGymMembershipService(data: data);
    return response.data;
  } catch (e) {
    throw Exception("Failed to get gym membership: $e");
  }
}



}
