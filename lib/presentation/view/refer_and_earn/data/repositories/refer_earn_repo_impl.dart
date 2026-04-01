import 'dart:developer';

import 'package:orka_sports/core/utils/error_handling.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/data/datasources/refer_earn_services.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/data/models/get_referral_model.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/domain/repositories/refer_earn_repo.dart';

class ReferEarnRepoImpl extends ReferEarnServices implements ReferEarnRepo {
  //Repo function to get referral dashboard
  @override
  Future<GetReferralDashModel> getReferralRepo({required Map<String, dynamic> data}) async {
    try {
      final response = await getReferralDashService(data: data);
      GetReferralDashModel getReferralDashModel = GetReferralDashModel.fromJson(response.data);
      return getReferralDashModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }
}
