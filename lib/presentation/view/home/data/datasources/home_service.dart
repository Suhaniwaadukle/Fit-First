import 'package:dio/dio.dart';
import 'package:orka_sports/config/api_constants.dart';
import 'package:orka_sports/core/resources/api_interceptor.dart';

abstract class HomeService {
  final Dio dio = ApiInterceptor().dio;

  //Service function for getting all the users
  Future<Response<dynamic>> getAllUsersService() {
    final referral = dio.get(
      ApiConstants.getAllUsers,
    );
    return referral;
  }

  //Service function for getting all the partners
  Future<Response<dynamic>> getAllPartnersService({required Map<String, dynamic> data}) {
    final referral = dio.post(
      ApiConstants.getAllPartners,
      data: data,
    );
    return referral;
  }
}
