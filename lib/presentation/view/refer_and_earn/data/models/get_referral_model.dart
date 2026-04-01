import 'dart:convert';

GetReferralDashModel getReferralDashModelFromJson(String str) => GetReferralDashModel.fromJson(json.decode(str));

String getReferralDashModelToJson(GetReferralDashModel data) => json.encode(data.toJson());

class GetReferralDashModel {
  String? status;
  String? referralCode;
  String? totalEarned;
  String? referralsCount;
  List<Referral>? referrals;
  
  // ✅ NEW: Add these two fields
  int? totalCoins;
  CoinsBreakdown? coinsBreakdown;

  GetReferralDashModel({
    this.status,
    this.referralCode,
    this.totalEarned,
    this.referralsCount,
    this.referrals,
    // ✅ NEW: Add to constructor
    this.totalCoins,
    this.coinsBreakdown,
  });

  factory GetReferralDashModel.fromJson(Map<String, dynamic> json) => GetReferralDashModel(
        status: json["status"],
        referralCode: json["referral_code"],
        totalEarned: json["total_earned"].toString(),
        referralsCount: json["referrals_count"].toString(),
        referrals: json["referrals"] == null ? [] : List<Referral>.from(json["referrals"]!.map((x) => Referral.fromJson(x))),
        
        // ✅ NEW: Parse the new fields
        totalCoins: json["total_coins"],
        coinsBreakdown: json["coins_breakdown"] != null 
          ? CoinsBreakdown.fromJson(json["coins_breakdown"]) 
          : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "referral_code": referralCode,
        "total_earned": totalEarned,
        "referrals_count": referralsCount,
        "referrals": referrals == null ? [] : List<dynamic>.from(referrals!.map((x) => x.toJson())),
        
        // ✅ NEW: Add to toJson
        "total_coins": totalCoins,
        "coins_breakdown": coinsBreakdown?.toJson(),
      };
}

// ✅ NEW: Add CoinsBreakdown class
class CoinsBreakdown {
  final int workout;
  final int walk;
  final int run;
  final int cycling;
  final int referrals;

  CoinsBreakdown({
    required this.workout,
    required this.walk,
    required this.run,
    required this.cycling,
    required this.referrals,
  });

  factory CoinsBreakdown.fromJson(Map<String, dynamic> json) => CoinsBreakdown(
        workout: json["workout"] ?? 0,
        walk: json["walk"] ?? 0,
        run: json["run"] ?? 0,
        cycling: json["cycling"] ?? 0,
        referrals: json["referrals"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "workout": workout,
        "walk": walk,
        "run": run,
        "cycling": cycling,
        "referrals": referrals,
      };
}

// ✅ EXISTING: Keep your existing Referral class unchanged
class Referral {
  String? id;
  String? referrerCode;
  String? referredUserId;
  String? rewardAmount;
  String? status;
  DateTime? createdAt;
  dynamic creditedAt;

  Referral({
    this.id,
    this.referrerCode,
    this.referredUserId,
    this.rewardAmount,
    this.status,
    this.createdAt,
    this.creditedAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
        id: json["id"],
        referrerCode: json["referrer_code"],
        referredUserId: json["referred_user_id"],
        rewardAmount: json["reward_amount"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        creditedAt: json["credited_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "referrer_code": referrerCode,
        "referred_user_id": referredUserId,
        "reward_amount": rewardAmount,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "credited_at": creditedAt,
      };
}
