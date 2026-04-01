import 'package:dio/dio.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/lifestyle_model/get_lifestyle_model.dart';

import '../../data/models/dosha_models/get_dosha_diet_model.dart';
import '../../data/models/dosha_models/get_dosha_exercise_model.dart';
import '../../data/models/dosha_models/get_dosha_meditation_model.dart';
import '../../data/models/dosha_models/get_dosha_result_model.dart';
import '../../data/models/product_models/get_fullreco_product_model.dart';
import '../../data/models/product_models/get_productby_partner_mode.dart';
import '../../data/models/product_models/get_reco_products_model.dart';
import '../../data/models/diet_models/meal_recommendations_model.dart';

abstract class BodyIqRepo {
  // BodyIq repo
  // Insert user profile (step 1)
  Future<dynamic> inserUserInfo({required Map<String, dynamic> data});
  // Insert dosha/lifestyle quiz (step 2 & step 3)
  Future<dynamic> insertDoshaLifestyle({required Map<String, dynamic> data, required String screenType});
  // Insert health risk quiz (step 4)
  Future<dynamic> insertHealthRisk({required Map<String, dynamic> data});
  // Get dosha result (step 5)
  Future<GetDoshaResultModel> getDoshaResultProfile({required Map<String, dynamic> data});
  Future<GetLifeStyleResultModel> getLifeStyleResult({required Map<String, dynamic> data});
  // Get dosha recommendatin (step 6)
  Future<GetDoshaRecoDietModel> getDoshaDiet({required Map<String, dynamic> data});
  Future<GetDoshaRecoMeditationModel> getDoshaMeditation({required Map<String, dynamic> data});
  Future<GetDoshaRecoExerciseModel> getDoshaExercise({required Map<String, dynamic> data});
  // Get recommendation products (step 7)
  Future<GetRecoProductModel> getRecoProduct({required Map<String, dynamic> data});
  Future<GetProductByPartnerModel> getRecoProductPartner({required Map<String, dynamic> data});
  Future<GetFullRecoProductModel> getFullRecoProduct({required Map<String, dynamic> data});
    // ADD THESE TWO METHOD SIGNATURES
  Future<MealRecommendationsResponse> getFoodItemsByMealAndDosha({
    required String userId,
    required String doshaResult,
    required String meal,
    required int foodType,
  });

  Future<AddFoodResponse> addFoodItemToMeal({
    required String userId,
    required String meal,
    required List<int> itemIds,
    required String day,
    bool forceReplaceGym = false,
  });
    //  NEW: Get user's added meal items
  Future<Map<String, dynamic>> getUserMealItems({
    required String userId,
    required String meal,
  });
  Future<Response> saveSingleMealTime({required Map<String, dynamic> data});
  Future<Response> deleteFoodItemToMeal({required Map<String, dynamic> data});

}

