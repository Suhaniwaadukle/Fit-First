import 'package:dio/dio.dart';
import 'package:orka_sports/config/api_constants.dart';
import 'package:orka_sports/core/resources/api_interceptor.dart';

abstract class BodyIqService {
  final Dio dio = ApiInterceptor().dio;

  // Service function for insert user info (step 1)
  Future<Response<dynamic>> insertUserInfoProfile({required Map<String, dynamic> data}) {
    final userInfo = dio.post(
      ApiConstants.userInfoProfile,
      data: data,
    );
    return userInfo;
  }

  // Service function for insert dosha/lifestyle quiz (step 2 & 3)
  Future<Response<dynamic>> insertDoshaLifestyleQuiz({required Map<String, dynamic> data, required String screenType}) {
    final doshaQuiz = dio.post(
      screenType == 'Dosha' ? ApiConstants.insertDoshaQuiz : ApiConstants.insertLifestyleQuiz,
      data: data,
    );
    return doshaQuiz;
  }

  // Service function for insert health rik quiz (step 4)
  Future<Response<dynamic>> insertHealthRiskQuiz({required Map<String, dynamic> data}) {
    final healthQuiz = dio.post(
      ApiConstants.insertHealthRiskQuiz,
      data: data,
    );
    return healthQuiz;
  }

  // Service function for dosha result (step 5)
  Future<Response<dynamic>> getDoshaResult({required Map<String, dynamic> data}) {
    final doshaResult = dio.post(
      ApiConstants.getDoshaResult,
      data: data,
    );
    return doshaResult;
  }

  Future<Response<dynamic>> getLifestyleResult({required Map<String, dynamic> data}) {
    final getLifeStyle = dio.post(
      ApiConstants.getLifeStyleResult,
      data: data,
    );
    return getLifeStyle;
  }

  // Service function for dosha recommendation (step 6)
  Future<Response<dynamic>> getDoshaRecoDiet({required Map<String, dynamic> data}) {
    final doshaRec = dio.post(
      ApiConstants.getDoshaRecoDiet,
      data: data,
    );
    return doshaRec;
  }

  Future<Response<dynamic>> getDoshaRecoMeditation({required Map<String, dynamic> data}) {
    final doshaRec = dio.post(
      ApiConstants.getDoshaRecoMeditation,
      data: data,
    );
    return doshaRec;
  }

  Future<Response<dynamic>> getDoshaRecoExercise({required Map<String, dynamic> data}) {
    final doshaRec = dio.post(
      ApiConstants.getDoshaRecoExercise,
      data: data,
    );
    return doshaRec;
  }

  // Service function for product recommendation (step 7)
  Future<Response<dynamic>> getRecoProducts({required Map<String, dynamic> data}) {
    final recProduct = dio.post(
      ApiConstants.getRecoProducts,
      data: data,
    );
    return recProduct;
  }

  Future<Response<dynamic>> getRecoProductsByPartner({required Map<String, dynamic> data}) {
    final recoByPartner = dio.post(
      ApiConstants.getRecoProductsByPartner,
      data: data,
    );
    return recoByPartner;
  }

  Future<Response<dynamic>> getRecoFullProducts({required Map<String, dynamic> data}) {
    final recoFullProduct = dio.post(
      ApiConstants.getFullRecoProducts,
      data: data,
    );
    return recoFullProduct;
  }

    // ADD THESE TWO METHODS
  // Future<Response<dynamic>> getFoodItemsByMealAndDosha({required Map<String, dynamic> data}) {
  //   return dio.post(ApiConstants.getFoodItemsByMealAndDosha, data: data);
  // }
  Future<Response<dynamic>> getFoodItemsByMealAndDosha({required Map<String, dynamic> data}) {
  return dio.post(
    'https://fitfirst.online/Api/getFoodItemsByMealAndDosha', // ✅ Direct URL
    data: data,
    options: Options(
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
}


  Future<Response<dynamic>> addFoodItemToMeal({required Map<String, dynamic> data}) {
    return dio.post(ApiConstants.addFoodItemToMeal, data: data);
  }
  // Add this method to your abstract BodyIqService class
//Future<Response> getFoodItemsByMealForUser({required Map<String, dynamic> data});

// Add this to your existing BodyIqService class
Future<Response> getFoodItemsByMealForUser({required Map<String, dynamic> data}) async {
  try {
    final response = await dio.post(
      'https://fitfirst.online/Api/getFoodItemsByMealForUser',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    return response;
  } catch (e) {
    print('Service error: $e');
    throw e;
  }
}
Future<Response> saveSingleMealTimeService({required Map<String, dynamic> data}) async {
  try {
    print('=== BODY IQ SERVICE: SAVING MEAL TIME ===');
    print('URL: https://fitfirst.online/Api/saveSingleMealTime');
    print('Request Data: $data');
    
    final response = await dio.post(
      'https://fitfirst.online/Api/saveSingleMealTime',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    print('=== MEAL TIME SERVICE: RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    print('=== MEAL TIME SERVICE: DIO ERROR ===');
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Response: ${e.response?.data}');
    throw e;
  } catch (e) {
    print('=== MEAL TIME SERVICE: GENERAL ERROR ===');
    print('Error: $e');
    throw e;
  }
}
Future<Response> deleteFoodItemToMealService({required Map<String, dynamic> data}) async {
  try {
    print('=== BODY IQ SERVICE: DELETING FOOD ITEMS ===');
    print('URL: https://fitfirst.online/Api/deleteFoodItemToMeal');
    print('Request Data: $data');
    
    final response = await dio.post(
      'https://fitfirst.online/Api/deleteFoodItemToMeal',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    print('=== DELETE SERVICE: RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    print('=== DELETE SERVICE: DIO ERROR ===');
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Response: ${e.response?.data}');
    throw e;
  } catch (e) {
    print('=== DELETE SERVICE: GENERAL ERROR ===');
    print('Error: $e');
    throw e;
  }
}



}
