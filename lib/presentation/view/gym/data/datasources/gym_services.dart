import 'package:dio/dio.dart';
import 'package:orka_sports/config/api_constants.dart';
import 'package:orka_sports/core/resources/api_interceptor.dart';

abstract class GymServices {
  final Dio dio = ApiInterceptor().dio;

  //Service function for getting gym goals
  Future<Response<dynamic>> getGymGoalsService({required Map<String, dynamic> data}) {
    final gymGoals = dio.post(
      ApiConstants.getGymGoals,
      data: data,
    );
    return gymGoals;
  }

  //Service function for searching gym
  Future<Response<dynamic>> searchGymService({required Map<String, dynamic> data}) {
    final searchGym = dio.post(
      ApiConstants.searchGym,
      data: data,
    );
    return searchGym;
  }

  //Service function to get near by gym
  Future<Response<dynamic>> getNearGymService({required Map<String, dynamic> data}) {
    final nearGym = dio.post(
      ApiConstants.getNearGym,
      data: data,
    );
    return nearGym;
  }

  //Service function to get gym details
  Future<Response<dynamic>> getGymDetailsService({required Map<String, dynamic> data}) {
    final gymDetails = dio.post(
      ApiConstants.getGymDetails,
      data: data,
    );
    return gymDetails;
  }

  //Service function to get gym buddy list
  Future<Response<dynamic>> getGymBuddyService({required Map<String, dynamic> data}) {
    final gymBuddy = dio.post(
      ApiConstants.getGymBuddy,
      data: data,
    );
    return gymBuddy;
  }

  //Service function to get gym details
  Future<Response<dynamic>> getGymBuddyDetailsService({required Map<String, dynamic> data}) {
    final gymBuddyDetails = dio.post(
      ApiConstants.getGymBuddyDetails,
      data: data,
    );
    return gymBuddyDetails;
  }

  //Service function to request gym buddy
  Future<Response<dynamic>> requestGymBuddyService({required Map<String, dynamic> data}) {
    final requestGymBuddy = dio.post(
      ApiConstants.getGymBuddyRequest,
      data: data,
    );
    return requestGymBuddy;
  }

  //Service function to verify gym code
  Future<Response<dynamic>> verifyGymCodeService({required Map<String, dynamic> data}) {
    final verifyCode = dio.post(
      ApiConstants.verifyGymCode,
      data: data,
    );
    return verifyCode;
  }

  //Service function to get sub industry
  Future<Response<dynamic>> getSubIndustryService({required Map<String, dynamic> data}) {
    final subIndustry = dio.post(
      ApiConstants.getSubIndustry,
      data: data,
    );
    return subIndustry;
  }

  //Service function to get near by gym by type (sub industry type)
  Future<Response<dynamic>> getNearByGymByTypeService({required Map<String, dynamic> data}) {
    final nearGymType = dio.post(
      ApiConstants.getNearGymByType,
      data: data,
    );
    return nearGymType;
  }

  //Service function to request gym partner
  Future<Response<dynamic>> requestGymPartnerService({required Map<String, dynamic> data}) {
    final requestGymPartner = dio.post(
      ApiConstants.requestGymPartner,
      data: data,
    );
    return requestGymPartner;
  }

  //Service function to get coaches list
  Future<Response<dynamic>> getCoachesListService({required Map<String, dynamic> data}) {
    final getCoachesList = dio.post(
      ApiConstants.getCoachesList,
      data: data,
    );
    return getCoachesList;
  }

  //Service function to get coaches details
  Future<Response<dynamic>> getCoachesDetailsService({required Map<String, dynamic> data}) {
    final getCoachesDetails = dio.post(
      ApiConstants.getCoachesDetails,
      data: data,
    );
    return getCoachesDetails;
  }
  // ✅ ADD THESE TO YOUR EXISTING GYMSERVICE CLASS

Future<Response> getGymFoodItemsByMealService({required Map<String, dynamic> data}) async {
  try {
    final response = await dio.post(
      'https://fitfirst.online/Api/getFoodItemsByMealForGym',
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

Future<Response<dynamic>> addGymFoodItemToMealService({required Map<String, dynamic> data}) async {
  try {
    final response = await dio.post(
      'https://fitfirst.online/Api/addFoodItemToMealForGym',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return response;
  } on DioException catch (e) {
    // ✅ IF IT'S A CONFLICT RESPONSE, RETURN IT INSTEAD OF THROWING
    if (e.response != null && 
        e.response!.data != null && 
        e.response!.data['status'] == 'confirm') {
      print('=== HANDLING CONFLICT RESPONSE ===');
      print('Conflict Response: ${e.response!.data}');
      return e.response!;
    }
    throw e;
  }
}


// ✅ ADD TO GYM SERVICES

Future<Response> getUserGymMealItemsService({required Map<String, dynamic> data}) async {
  try {
    final response = await dio.post(
      'https://fitfirst.online/Api/getGymFoodItemsByMealForUser',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    print('=== SERVICE RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    return response;
  } catch (e) {
    print('=== SERVICE ERROR ===');
    print('Error: $e');
    throw e;
  }
}
// Add this method to your GymServices class
Future<Response> getTargetCaloriesService({required Map<String, dynamic> data}) async {
  try {
    print('=== GYM SERVICE: FETCHING TARGET CALORIES ===');
    print('URL: https://fitfirst.online/Api/getTargetCalories');
    print('Request Data: $data');
    
    final response = await dio.post(
      'https://fitfirst.online/Api/getTargetCalories',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    print('=== GYM SERVICE: TARGET CALORIES RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    print('=== GYM SERVICE: TARGET CALORIES DIO ERROR ===');
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Response: ${e.response?.data}');
    throw e;
  } catch (e) {
    print('=== GYM SERVICE: TARGET CALORIES GENERAL ERROR ===');
    print('Error: $e');
    throw e;
  }
}
// Add this method to your GymServices class
Future<Response> generateMealPlanByCaloriesService({required Map<String, dynamic> data}) async {
  try {
    print('=== GYM SERVICE: GENERATING MEAL PLAN ===');
    print('URL: https://fitfirst.online/Api/generateMealPlanByCaloriesForGym');
    print('Request Data: $data');
    
    final response = await dio.post(
      'https://fitfirst.online/Api/generateMealPlanByCaloriesForGym',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    print('=== GYM SERVICE: MEAL PLAN RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    print('=== GYM SERVICE: MEAL PLAN DIO ERROR ===');
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Response: ${e.response?.data}');
    throw e;
  } catch (e) {
    print('=== GYM SERVICE: MEAL PLAN GENERAL ERROR ===');
    print('Error: $e');
    throw e;
  }
}
Future<Response> saveSingleMealTimeService({required Map<String, dynamic> data}) async {
  try {
    print('=== GYM SERVICE: SAVING MEAL TIME ===');
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
    
    print('=== GYM SERVICE: RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    print('=== GYM SERVICE: DIO ERROR ===');
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Response: ${e.response?.data}');
    throw e;
  } catch (e) {
    print('=== GYM SERVICE: GENERAL ERROR ===');
    print('Error: $e');
    throw e;
  }
}

Future<Response> deleteFoodItemToMealService({required Map<String, dynamic> data}) async {
  try {
    print('=== GYM SERVICE: DELETING FOOD ITEMS ===');
    print('URL: https://fitfirst.online/Api/deleteGymFoodItemToMeal');
    print('Request Data: $data');
    
    final response = await dio.post(
      'https://fitfirst.online/Api/deleteGymFoodItemToMeal',
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    print('=== GYM DELETE SERVICE: RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Data: ${response.data}');
    
    return response;
  } on DioException catch (e) {
    print('=== GYM DELETE SERVICE: DIO ERROR ===');
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Response: ${e.response?.data}');
    throw e;
  } catch (e) {
    print('=== GYM DELETE SERVICE: GENERAL ERROR ===');
    print('Error: $e');
    throw e;
  }
}
//Service function to check user's current gym membership status
Future<Response<dynamic>> getUserGymMembershipService({required Map<String, dynamic> data}) {
  final getUserGymMembership = dio.post(
    "https://fitfirst.online/Api/getUserGymMembership",
    data: data,
  );
  return getUserGymMembership;
}



}
