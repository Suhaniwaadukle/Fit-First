import 'dart:developer';

import 'package:dio/dio.dart';
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
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_diet_tracking_screen.dart';

abstract class GymRepo {
  // Repo function for gym goals
  Future<GetGymGoalsModel> getGymGoalsRepo({required Map<String, dynamic> data});
  
  // Repo function for searching gym
  Future<SearchGymModel> searchGymRepo({required Map<String, dynamic> data});
  
  // Repo function for getting near gym
  Future<GetNearGymModel> getNearGymRepo({required Map<String, dynamic> data});
  
  // Repo function to get gym details
  Future<GetGymDetailsModel> getGymDetailsRepo({required Map<String, dynamic> data});
  
  // Repo function to get gym buddy
  Future<GetGymBuddyModel> getGymBuddyRepo({required Map<String, dynamic> data});
  
  // Repo function to get gym buddy details
  Future<GetGymBuddyDetailsModel> getGymBuddyDetailsRepo({required Map<String, dynamic> data});
  
  // Repo function to request gym buddy
  Future<dynamic> requestGymBuddyRepo({required Map<String, dynamic> data});
  
  // Repo function to verify gym code
  Future<dynamic> verifyGymCodeRepo({required Map<String, dynamic> data});
  
  // Repo function to get sub industry
  Future<GetSubIndustryModel> getSubIndustryRepo({required Map<String, dynamic> data});
  
  // Repo function to get near by gym by sub industry type
  Future<GetNearGymModel> getNearByGymByTypeRepo({required Map<String, dynamic> data});
  
  // Repo function to request the gym partner
  Future<dynamic> requestGymPartnerRepo({required Map<String, dynamic> data});
  
  // Repo function to get all coaches list
  Future<GetCoachesListModel> getCoachesListRepo({required Map<String, dynamic> data});
  
  // Repo function to get coaches details
  Future<GetCoachesDetailsModel> getCoachesDetailsRepo({required Map<String, dynamic> data});

  // ✅ NEW GYM FOOD METHOD DECLARATIONS (ABSTRACT ONLY)
  
  // Repo function to get gym food items by meal
  Future<GymMealRecommendationsResponse> getGymFoodItemsByMeal({
    required String userId,
    required String meal,
    required int foodType,
  });

  // Repo function to add gym food items to meal
  Future<Map<String, dynamic>> addGymFoodItemToMeal({
    required String userId,
    required String meal,
    required List<int> itemIds,
    required String day,
    bool forceReplaceBodyIq = false,
  });
  // ✅ ADD TO GYM REPO INTERFACE
Future<List<GymAddedMealItem>> getUserGymMealItems({
  required String userId,
  required String meal,
});
// Add this method to your abstract GymRepo class
Future<TargetCaloriesResponse> getTargetCalories({
  required String userId,
});
// Add this method signature to your GymRepo abstract class
Future<MealPlanResponse> generateMealPlanByCalories({
  required String userId,
});
Future<Response> saveSingleMealTime({required Map<String, dynamic> data});
Future<Response> deleteFoodItemToMeal({required Map<String, dynamic> data});
Future<Map<String, dynamic>> getUserGymMembershipRepo({required Map<String, dynamic> data});





}
