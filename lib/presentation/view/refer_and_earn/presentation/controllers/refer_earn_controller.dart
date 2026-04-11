// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:orka_sports/app/widgets/common_dialogs/common_dialogs.dart';
import 'package:orka_sports/app/widgets/common_formatter/common_formatter.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/data/repositories/refer_earn_repo_impl.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/domain/entities/refer_earn_entity.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/domain/repositories/refer_earn_repo.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferEarnController extends StateNotifier<ReferEarnEntity> {
  ReferEarnController() : super(ReferEarnEntity.initial());
  final ReferEarnRepo _referEarnRepo = ReferEarnRepoImpl();
  final SharedPreferences prefs = GetItService.getIt<SharedPreferences>();
  final CommonFormatter formatter = CommonFormatter();

  // Function to get referral dashboard
  Future<void> getReferralDashboard(BuildContext context) async {
    try {
      state = state.copyWith(
        isReferralLoading: true,
      );
      await _referEarnRepo.getReferralRepo(data: {
        "user_id": prefs.getString("userId"),
      }).then(
        (value) {
          log("Success referral $value");
          state = state.copyWith(
            getReferralList: value,
          );
        },
      );
    } catch (e) {
      showCustomPopup(
        context,
        title: "Something went wrong!",
        message: e.toString(),
        iconData: Icons.info_outline,
        okButtonText: 'Ok',
        cancelButtonText: '',
        onCancelPressed: null,
      );
    } finally {
      state = state.copyWith(
        isReferralLoading: false,
      );
    }
  }

  // void shareReferral(BuildContext context) {
  //   final message =
  //       "Hey! Join Orka Strive using my referral code ${state.getReferralList.referralCode} and get exciting rewards. Download now: https://play.google.com/store/apps/details?id=com.orkasports.app&hl=en";
  //   SharePlus.instance.share(
  //     ShareParams(
  //       text: message,
  //       subject: 'Join me on Orka Strive!',
  //     ),
  //   );
  // }

  void shareReferral(BuildContext context) {
    final referralCode = state.getReferralList.referralCode ?? "YOURCODE";
    final message = '''
Fitness • Nutrition • Lifestyle – Simplified
Your All-in-One Wellness Partner 💪🥗🧠
Work Out. Eat Smart. Live Better.

🚀 Download the Fit First App Now ⬇️
And hey! Join using my referral code: $referralCode to unlock exclusive rewards 🎁
👉 https://play.google.com/store/apps/details?id=com.orkasports.app&hl=en
''';

    SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'Join me on Fit First!',
      ),
    );
  }
}
