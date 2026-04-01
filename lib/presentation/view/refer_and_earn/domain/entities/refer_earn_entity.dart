import 'package:flutter/material.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/data/models/get_referral_model.dart';

@immutable
class ReferEarnEntity {
  final bool isReferralLoading;
  final GetReferralDashModel getReferralList;

  const ReferEarnEntity({
    required this.isReferralLoading,
    required this.getReferralList,
  });

  factory ReferEarnEntity.initial() {
    return ReferEarnEntity(
      isReferralLoading: false,
      getReferralList: GetReferralDashModel(),
    );
  }

  ReferEarnEntity copyWith({
    bool? isReferralLoading,
    GetReferralDashModel? getReferralList,
  }) {
    return ReferEarnEntity(
      isReferralLoading: isReferralLoading ?? this.isReferralLoading,
      getReferralList: getReferralList ?? this.getReferralList,
    );
  }
}
