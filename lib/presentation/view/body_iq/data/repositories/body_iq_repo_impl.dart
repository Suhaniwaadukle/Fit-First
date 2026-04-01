import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:orka_sports/core/utils/error_handling.dart';
import 'package:orka_sports/presentation/view/body_iq/data/datasources/body_iq_service.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/diet_models/meal_recommendations_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/dosha_models/get_dosha_diet_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/dosha_models/get_dosha_exercise_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/dosha_models/get_dosha_meditation_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/lifestyle_model/get_lifestyle_model.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/product_models/get_reco_products_model.dart';
import 'package:orka_sports/presentation/view/body_iq/domain/repositories/body_iq_repo.dart';
import '../models/dosha_models/get_dosha_result_model.dart';
import '../models/product_models/get_fullreco_product_model.dart';
import '../models/product_models/get_productby_partner_mode.dart';

class BodyIqRepoImpl implements BodyIqRepo {
  final BodyIqService _bodyIqService;
  
  BodyIqRepoImpl() : _bodyIqService = _BodyIqServiceImpl();
  
  // All your existing methods...
  @override
  Future<dynamic> inserUserInfo({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.insertUserInfoProfile(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<dynamic> insertDoshaLifestyle({required Map<String, dynamic> data, required String screenType}) async {
    try {
      final response = await _bodyIqService.insertDoshaLifestyleQuiz(data: data, screenType: screenType);
      return response.data;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<dynamic> insertHealthRisk({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.insertHealthRiskQuiz(data: data);
      return response.data;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetDoshaResultModel> getDoshaResultProfile({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getDoshaResult(data: data);
      GetDoshaResultModel getDoshaModel = GetDoshaResultModel.fromJson(response.data);
      return getDoshaModel;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetLifeStyleResultModel> getLifeStyleResult({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getLifestyleResult(data: data);
      GetLifeStyleResultModel getLifeStyleResultModel = GetLifeStyleResultModel.fromJson(response.data);
      return getLifeStyleResultModel;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetDoshaRecoDietModel> getDoshaDiet({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getDoshaRecoDiet(data: data);
      GetDoshaRecoDietModel getDoshaDiet = GetDoshaRecoDietModel.fromJson(response.data);
      return getDoshaDiet;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetDoshaRecoMeditationModel> getDoshaMeditation({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getDoshaRecoMeditation(data: data);
      GetDoshaRecoMeditationModel getDoshaMeditation = GetDoshaRecoMeditationModel.fromJson(response.data);
      return getDoshaMeditation;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetDoshaRecoExerciseModel> getDoshaExercise({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getDoshaRecoExercise(data: data);
      GetDoshaRecoExerciseModel getDoshaExercise = GetDoshaRecoExerciseModel.fromJson(response.data);
      return getDoshaExercise;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetRecoProductModel> getRecoProduct({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getRecoProducts(data: data);
      GetRecoProductModel getProduct = GetRecoProductModel.fromJson(response.data);
      return getProduct;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetProductByPartnerModel> getRecoProductPartner({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getRecoProductsByPartner(data: data);
      GetProductByPartnerModel getProduct = GetProductByPartnerModel.fromJson(response.data);
      return getProduct;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<GetFullRecoProductModel> getFullRecoProduct({required Map<String, dynamic> data}) async {
    try {
      final response = await _bodyIqService.getRecoFullProducts(data: data);
      GetFullRecoProductModel getProduct = GetFullRecoProductModel.fromJson(response.data);
      return getProduct;
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<MealRecommendationsResponse> getFoodItemsByMealAndDosha({
    required String userId,
    required String doshaResult,
    required String meal,
    required int foodType,
  }) async {
    try {
      final response = await _bodyIqService.getFoodItemsByMealAndDosha(data: {
        'user_id': int.parse(userId),
        'doshaResult': doshaResult,
        'meal': meal,
        'food_type': foodType,
      });
      return MealRecommendationsResponse.fromJson(response.data);
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<AddFoodResponse> addFoodItemToMeal({
    required String userId,
    required String meal,
    required List<int> itemIds,
    required String day,
    bool forceReplaceGym = false,
  }) async {
    try {
      final response = await _bodyIqService.addFoodItemToMeal(data: {
        'user_id': userId,
        'meal': meal,
        'item_id': itemIds,
        'day': day,
        'force_replace_gym': forceReplaceGym, 
      });
      return AddFoodResponse.fromJson(response.data);
    } catch (e) {
      log("error-- : $e");
      throw ErrorHandler.handleError(e);
    }
  }

  // ✅ ADD THIS MISSING METHOD
  @override
  Future<Map<String, dynamic>> getUserMealItems({
    required String userId,
    required String meal,
  }) async {
    try {
      print('=== REPO: Getting user meal items ===');
      print('User ID: $userId, Meal: $meal');
      
      final response = await _bodyIqService.getFoodItemsByMealForUser(data: {
        'user_id': int.parse(userId),
        'meal': meal,
      });
      
      print('=== REPO: API Response ===');
      print('Response: ${response.data}');
      
      return response.data;
    } catch (e) {
      log("error getUserMealItems: $e");
      // Return empty response to avoid breaking existing functionality
      return {
        'status': 'error', 
        'data': [], 
        'message': 'Failed to load user meal items: $e'
      };
    }
  }
  @override
Future<Response> saveSingleMealTime({required Map<String, dynamic> data}) async {
  return await _bodyIqService.saveSingleMealTimeService(data: data);
}
@override
Future<Response> deleteFoodItemToMeal({required Map<String, dynamic> data}) async {
  return await _bodyIqService.deleteFoodItemToMealService(data: data);
}


}

// Concrete implementation of abstract BodyIqService
class _BodyIqServiceImpl extends BodyIqService {
  // This class provides concrete implementation of the abstract service
  // All methods are already implemented in the parent abstract class
}
