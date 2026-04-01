import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_listview/common_listview.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';

class ReferAndEarnScreen extends StatelessWidget {
  const ReferAndEarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final referState = ref.watch(DiProviders.referralControllerProvider);
      final referProvider = ref.watch(DiProviders.referralControllerProvider.notifier);
      
      return Scaffold(
        appBar: CommonAppBar(
          title: "Refer & Earn",
          titleStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        body: referState.isReferralLoading
            ? CommonLoadingWidget()
            : referState.getReferralList.referralCode == '' ||
                    referState.getReferralList.referralCode == 'null' ||
                    referState.getReferralList.referralCode == null
                ? Center(
                    child: Text("No referral code found for this user!"),
                  )
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ✅ REFERRAL CODE SECTION
                        CommonContainerWithBorder(
                          radius: 10,
                          child: Column(
                            children: [
                              /// Network Illustration (UnDraw)
                              Icon(
                                CupertinoIcons.gift_fill,
                                color: AppColors.kPrimaryColor,
                                size: 100,
                              ),
                              const SizedBox(height: 20),

                              const Text(
                                "Invite your friends and earn rewards!",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Share your code with friends. You both get rewarded when they sign up!",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),

                              /// Referral Code Box
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      referState.getReferralList.referralCode ?? '',
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: referState.getReferralList.referralCode ?? ''));
                                        showCustomSnackbar(
                                          context,
                                          'Code copied!',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// Share Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => referProvider.shareReferral(context),
                                  icon: const Icon(Icons.share),
                                  label: Text(
                                    "Share Invite",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                          color: AppColors.kWhite,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                        
                        AppSize.kHeight15,
                        
                        // ✅ EXISTING STATS ROW
                        Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: CommonContainerWithBorder(
                                radius: 10,
                                padding: EdgeInsets.all(0),
                                child: CommonListTile(
                                  leading: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("assets/images/coin1.png"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  borderColor: Colors.transparent,
                                  title: "Total Earned",
                                  titleStyle: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                  subTitle: referState.getReferralList.totalEarned ?? "",
                                  subtitleStyle: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  isSubtitle: true,
                                ),
                              ),
                            ),
                            Expanded(
                              child: CommonContainerWithBorder(
                                radius: 10,
                                padding: EdgeInsets.all(0),
                                child: CommonListTile(
                                  leading: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Icon(
                                      Icons.group,
                                    ),
                                  ),
                                  borderColor: Colors.transparent,
                                  title: "No.of Referrals",
                                  titleStyle: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                  subTitle: referState.getReferralList.referralsCount ?? "",
                                  subtitleStyle: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                  isSubtitle: true,
                                ),
                              ),
                            )
                          ],
                        ),
                        
                        AppSize.kHeight15,
                        
                        // ✅ NEW: TOTAL COINS SECTION  
                        CommonContainerWithBorder(
                          radius: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Total Coins Header
                              Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.kPrimaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Icon(
                                      Icons.monetization_on, 
                                      color: AppColors.kPrimaryColor, 
                                      size: 24
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total Coins Earned",
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                        Text(
                                          "${referState.getReferralList.totalCoins ?? 0} Coins",
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: AppColors.kPrimaryColor, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 10),
                              
                              Text(
                                "Coins Breakdown", 
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // ✅ COINS BREAKDOWN LIST
                              if (referState.getReferralList.coinsBreakdown != null) ...[
                                _buildCoinsRow(
                                  "Workout", 
                                  referState.getReferralList.coinsBreakdown!.workout, 
                                  Icons.fitness_center
                                ),
                                _buildCoinsRow(
                                  "Walking", 
                                  referState.getReferralList.coinsBreakdown!.walk, 
                                  Icons.directions_walk
                                ),
                                _buildCoinsRow(
                                  "Running", 
                                  referState.getReferralList.coinsBreakdown!.run, 
                                  Icons.directions_run
                                ),
                                _buildCoinsRow(
                                  "Cycling", 
                                  referState.getReferralList.coinsBreakdown!.cycling, 
                                  Icons.pedal_bike
                                ),
                                
                              ],
                            ],
                          ),
                        ),
                        
                        AppSize.kHeight10,
                      ],
                    ),
                  ),
      );
    });
  }

  // ✅ NEW: Helper method for coins breakdown rows
  Widget _buildCoinsRow(String title, int coins, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.kPrimaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title, 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: coins > 0 
                ? AppColors.kPrimaryColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "$coins", 
              style: TextStyle(
                color: coins > 0 ? AppColors.kPrimaryColor : Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
