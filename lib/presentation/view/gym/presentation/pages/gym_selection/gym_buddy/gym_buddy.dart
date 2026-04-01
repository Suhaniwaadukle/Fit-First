import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_dropdowns/common_dropdowns.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';

class GymBuddyListingScreen extends StatefulWidget {
  const GymBuddyListingScreen({super.key});

  @override
  State<GymBuddyListingScreen> createState() => _BuddyListingScreenState();
}

class _BuddyListingScreenState extends State<GymBuddyListingScreen> {
  
  // ✅ RIGHT SIDE RATING WIDGET (ONLY AVG_RATING)
  Widget _buildRatingWidget(String? avgRating) {
    final rating = double.tryParse(avgRating ?? '0') ?? 0.0;
    
    // Show "New" badge for unrated buddies
    if (rating == 0.0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'New',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(rating).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: _getRatingColor(rating),
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getRatingColor(rating),
            ),
          ),
        ],
      ),
    );
  }
  
  // ✅ HELPER METHOD TO GET RATING COLOR
  Color _getRatingColor(double rating) {
    if (rating >= 4.0) {
      return Colors.green;
    } else if (rating >= 3.0) {
      return Colors.orange;
    } else if (rating >= 1.0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final gymState = ref.watch(DiProviders.gymControllerProvider);
      final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);
      const experiences = ['All', 'Beginner', 'Intermediate', 'Advanced'];
      
      return Scaffold(
        appBar: CommonAppBar(
          title: "All Gym Buddies List",
          titleStyle: Theme.of(context).textTheme.headlineSmall,
        ),
        body: SafeArea(
          child: gymState.isGymBuddyLoading
              ? CommonLoadingWidget()
              : (gymState.getGymBuddyList.data?.isEmpty ?? false) || gymState.getGymBuddyList.data == null
                  ? Center(
                      child: Text(gymState.getGymBuddyList.message ?? ''),
                    )
                  : Padding(
                      padding: AppPaddings.backgroundPAll,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Find Your\nGym Buddy",
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          AppSize.kHeight15,
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Filters",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: CommonDropDownWidget(
                                  radius: 30,
                                  items: experiences,
                                  primaryValue: gymState.selectedExperience,
                                  widgetIcon: const Icon(Icons.tune_rounded),
                                  onDropDwChanged: (value) {
                                    if (value != null) {
                                      gymProvider.updateExperienceFilter(value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          AppSize.kHeight20,
                          Expanded(
                            child: RefreshIndicator.adaptive(
                              onRefresh: () {
                                return gymProvider.getGymBuddy(context);
                              },
                              child: ListView.builder(
                                itemCount: gymState.getGymBuddyList.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final buddy = gymState.getGymBuddyList.data?[index];
                                  return GestureDetector(
                                    onTap: () {
                                      gymProvider.onGymBuddyDetailsOnTap(context, buddyId: buddy?.id ?? '');
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // ✅ BUDDY AVATAR
                                          CircleAvatar(
                                            radius: 32,
                                            backgroundImage: (buddy?.image != null && buddy!.image!.isNotEmpty)
                                                ? NetworkImage(buddy.image!)
                                                : null,
                                            backgroundColor: Colors.grey[300],
                                            child: (buddy?.image == null || buddy!.image!.isEmpty)
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 30,
                                                    color: Colors.grey,
                                                  )
                                                : null,
                                          ),
                                          
                                          const SizedBox(width: 16),
                                          
                                          // ✅ BUDDY INFO (LEFT SIDE)
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Name
                                                Text(
                                                  buddy?.name ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF111827),
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                
                                                const SizedBox(height: 4),
                                                
                                                // Age and Experience
                                                Text(
                                                  "Age: ${buddy?.age ?? '-'} • Exp: ${buddy?.fitnessLevel ?? 'Not specified'}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _buildRatingWidget(buddy?.avgRating),
                                              
                                              const SizedBox(height: 8),

                                              const Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      );
    });
  }
}
