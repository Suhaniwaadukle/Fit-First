import 'package:dio/dio.dart';
import 'package:orka_sports/config/api_constants.dart';
import 'package:orka_sports/core/resources/api_interceptor.dart';

abstract class ReferEarnServices {
  final Dio dio = ApiInterceptor().dio;

  //Service function for referral dashboard
  Future<Response<dynamic>> getReferralDashService({required Map<String, dynamic> data}) {
    final referral = dio.post(
      ApiConstants.getReferralDashboard,
      data: data,
    );
    return referral;
  }
}
