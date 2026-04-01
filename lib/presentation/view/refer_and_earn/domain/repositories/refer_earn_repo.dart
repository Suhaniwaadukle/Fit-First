import 'package:orka_sports/presentation/view/refer_and_earn/data/models/get_referral_model.dart';

abstract class ReferEarnRepo {
  // Repo function to get referral dashboard
  Future<GetReferralDashModel> getReferralRepo({required Map<String, dynamic> data});
}
