import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/view/body/gear_screen/gear_screen.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/near_by_gym/near_by_gym.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/search_by_gym/search_by_gym.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../home/data/models/get_allpartners_model.dart';
import '../../../../home/data/repositories/home_repo_impl.dart';
import '../../../../home/presentation/pages/all_partners_screen.dart';
import '../../../../home/presentation/pages/home_screen.dart';
import '../../../../home/presentation/pages/partner_details_screen.dart';

class GymSelectionScreen extends ConsumerStatefulWidget {
  const GymSelectionScreen({super.key});

  @override
  ConsumerState<GymSelectionScreen> createState() => _GymSelectionScreenState();
}

class _GymSelectionScreenState extends ConsumerState<GymSelectionScreen> {
  Future<GetAllPartnersModel> _loadPartnersDirectly() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    if (userId == null || userId.isEmpty) {
      throw Exception('No user ID found');
    }

    final homeRepoImpl = HomeRepoImpl();

    return await homeRepoImpl.getAllPartnersRepo(data: {
      "user_id": userId,
    });
  }

  Partner convertToPartner(AllPartnersModel apiPartner) {
    return Partner(
      id: apiPartner.partnerId ?? '',
      name: apiPartner.partnerName ?? 'Unknown Partner',
      type: 'Partner',
      specialization: 'Fitness Center',
      rating: 4.5,
      distance: double.tryParse(apiPartner.distance ?? '0.0') ?? 0.0,
      imageUrl: apiPartner.partnerProfile ?? 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      level: 'All Levels',
      price: 0,
      isOnline: true,
      address: 'Location available',
      hours: 'Open today',
      amenities: ['Fitness', 'Training'],
      productsAndServices: apiPartner.productsAndServices
          ?.map((product) => product.toJson())
          .toList() ?? [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gymState = ref.watch(DiProviders.gymControllerProvider);
    final gymProvider = ref.watch(DiProviders.gymControllerProvider.notifier);
    return Scaffold(
      appBar: CommonAppBar(
        title: "Choose Your Gym",
        titleStyle: Theme
            .of(context)
            .textTheme
            .headlineSmall,
        actions: [
          Row(
            children: [
              _buildTextButton(
                "Nutrition",
                onPressed: () {
                  context.read<ActivitySubCategoryBloc>().add(
                    LoadSubCategories(
                        activityId: "28", activityType: 'Nutrition'),
                  );
                  CustomSmoothNavigator.push(
                    context,
                    NutritionScreen(
                        activityId: "28", activityType: 'Nutrition'),
                  );
                },
              ),
              _buildTextButton(
                "Gear",
                onPressed: () {
                  context.read<ActivitySubCategoryBloc>().add(
                    LoadSubCategories(activityId: "28", activityType: 'Gear'),
                  );
                  CustomSmoothNavigator.push(
                    context,
                    GearScreen(activityId: "28", activityType: 'Gear'),
                  );
                },
              ),
              AppSize.kWidth10,
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildOptionCard('existing', 'I Already Have a Gym Membership',
                'Enter your gym details',
                Icons.card_membership, gymProvider, gymState),
            const SizedBox(height: 16),
            _buildOptionCard('looking', 'I\'m Looking for a Gym Near Me',
                'Explore partner gyms nearby',
                Icons.location_on, gymProvider, gymState),

            if (gymState.selectedMembershipOption == 'existing')
              const SizedBox(height: 10),
              ExistingGymWidget(
                controller: gymState.searchGymController,
                onCheckPartnership: () {
                  gymProvider.searchGymFn(context);
                },
                gymController: gymProvider,
                gymEntity: gymState,
              ),

            if (gymState.selectedMembershipOption == 'looking')
              NearbyGymsWidget(
                gymController: gymProvider,
                gymEntity: gymState,
                onSelect: (index) {
                  gymProvider.selectGymIndex(index);
                },
              ),

              // buildEnhancedPartnersSection(ref),
          ],
        ),
      ),
    );
  }

  Widget buildEnhancedPartnersSection(WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby you ',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          buildPartnersContentDirect(),
        ],
      ),
    );
  }

  Widget buildPartnersContentDirect() {
    return FutureBuilder<GetAllPartnersModel>(
      future: _loadPartnersDirectly(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.kPrimaryColor),
                  const SizedBox(height: 12),
                  Text('Loading partners...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Container(
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 12),
                  Text('Error loading partners', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final partnersResponse = snapshot.data;
        if (partnersResponse?.data == null || partnersResponse!.data!.isEmpty) {
          return Container(
            height: 250,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('No partners found in your area', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Search Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final partners = partnersResponse.data!.map((apiPartner) => convertToPartner(apiPartner)).toList();

        return Container(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: partners.length,
            itemBuilder: (context, index) {
              final partner = partners[index];
              return Container(
                width: 320,
                margin: const EdgeInsets.only(right: 16),
                child: buildExactPartnerCard(partner),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildExactPartnerCard(Partner partner) {
    return InkWell(
      onTap: () {
        final homeState = ref.read(homeControllerProvider);
        final partnersData = homeState.getAllPartnersList?.data ?? [];

        final matchingPartner = partnersData.firstWhere(
              (apiPartner) => apiPartner.partnerId == partner.id,
          orElse: () => AllPartnersModel(),
        );

        final partnerCompleteData = {
          'partnerID': matchingPartner.partnerId ?? partner.id,
          'partnerName': matchingPartner.partnerName ?? partner.name,
          'partnerProfile': matchingPartner.partnerProfile ?? partner.imageUrl,
          'distance': matchingPartner.distance ?? partner.distance.toString(),
          'partnerLat': matchingPartner.partnerLat ?? '0.0',
          'partnerLong': matchingPartner.partnerLong ?? '0.0',
          'partner_image': matchingPartner.partnerImage,
          'about': matchingPartner.about,
          'mobile': matchingPartner.mobile,
          'start_time_monday': matchingPartner.startTimeMonday,
          'end_time_monday': matchingPartner.endTimeMonday,
          'start_time_tuesday': matchingPartner.startTimeTuesday,
          'end_time_tuesday': matchingPartner.endTimeTuesday,
          'start_time_wednesday': matchingPartner.startTimeWednesday,
          'end_time_wednesday': matchingPartner.endTimeWednesday,
          'start_time_thursday': matchingPartner.startTimeThursday,
          'end_time_thursday': matchingPartner.endTimeThursday,
          'start_time_friday': matchingPartner.startTimeFriday,
          'end_time_friday': matchingPartner.endTimeFriday,
          'start_time_saturday': matchingPartner.startTimeSaturday,
          'end_time_saturday': matchingPartner.endTimeSaturday,
          'start_time_sunday': matchingPartner.startTimeSunday,
          'end_time_sunday': matchingPartner.endTimeSunday,
          'product_subcategories': matchingPartner.productSubcategories,
          'products_and_services': matchingPartner.productsAndServices
              ?.map((product) => product.toJson())
              .toList() ?? [],
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerDetailsScreen(
              partner: partnerCompleteData,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // ✅ High-Quality Partner Image
              Container(
                height: 160,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: partner.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
                  memCacheWidth: (320 * MediaQuery.of(context).devicePixelRatio).round(),
                  memCacheHeight: (160 * MediaQuery.of(context).devicePixelRatio).round(),
                  filterQuality: FilterQuality.high,
                  placeholder: (context, url) => Container(
                    height: 160,
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.kPrimaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                      size: 40,
                    ),
                  ),
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 300),
                ),
              ),

              // Partner Info with Map Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Partner Name
                    Text(
                      partner.name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Distance/Timings and Map Button Row
                    Row(
                      children: [
                        // Left side - Distance and Timings
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildDistanceInfo(partner),
                              const SizedBox(height: 3),
                              buildTodayTimings(partner),
                            ],
                          ),
                        ),

                        // Right side - Map Button
                        SizedBox(
                          width: 85,
                          height: 28,
                          child: ElevatedButton.icon(
                            onPressed: () => openGoogleMaps(partner),
                            icon: const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Navigate',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDistanceInfo(Partner partner) {
    final homeState = ref.read(homeControllerProvider);
    final partnersData = homeState.getAllPartnersList?.data ?? [];

    final matchingPartner = partnersData.firstWhere(
          (apiPartner) => apiPartner.partnerId == partner.id,
      orElse: () => AllPartnersModel(),
    );

    final distance = matchingPartner.distance ?? '0.0';
    final distanceValue = double.tryParse(distance) ?? 0.0;

    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '${distanceValue.toStringAsFixed(1)} km away',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildTodayTimings(Partner partner) {
    final homeState = ref.read(homeControllerProvider);
    final partnersData = homeState.getAllPartnersList?.data ?? [];

    final matchingPartner = partnersData.firstWhere(
          (apiPartner) => apiPartner.partnerId == partner.id,
      orElse: () => AllPartnersModel(),
    );

    // Get today's day name
    final today = DateTime.now();
    final dayNames = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final todayName = dayNames[today.weekday - 1];

    final todayTiming = getTodayTiming(matchingPartner.toJson(), todayName);

    if (todayTiming.isNotEmpty) {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Open • $todayTiming',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Open',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      );
    }
  }
  Future<void> openGoogleMaps(Partner partner) async {
    try {
      final homeState = ref.read(homeControllerProvider);
      final partnersData = homeState.getAllPartnersList?.data ?? [];

      final matchingPartner = partnersData.firstWhere(
            (apiPartner) => apiPartner.partnerId == partner.id,
        orElse: () => AllPartnersModel(),
      );

      final lat = double.tryParse(matchingPartner.partnerLat ?? '0.0') ?? 0.0;
      final lng = double.tryParse(matchingPartner.partnerLong ?? '0.0') ?? 0.0;

      // Check if coordinates are valid
      if (lat == 0.0 && lng == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location not available for this partner'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create Google Maps URL with destination
      final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to basic maps URL
        final fallbackUrl = 'https://maps.google.com/?q=$lat,$lng';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Could not launch Google Maps';
        }
      }
    } catch (e) {
      debugPrint('Error launching Google Maps: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getTodayTiming(Map<String, dynamic> partner, String dayName) {
    final startTimeKey = 'start_time_$dayName';
    final endTimeKey = 'end_time_$dayName';

    final startTime = partner[startTimeKey]?.toString() ?? '';
    final endTime = partner[endTimeKey]?.toString() ?? '';

    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      return '$startTime - $endTime';
    }

    return '';
  }

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Let\'s find your gym',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
          const SizedBox(height: 8),
          Text('Choose your membership status to get started', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      );

  Widget _buildOptionCard(
      String value, String title, String subtitle, IconData icon, GymController gymController, GymEntity gymEntity) {
    final isSelected = gymEntity.selectedMembershipOption == value;
    return GestureDetector(
      onTap: () {
        gymController.selectMembershipOption(value);
        gymController.selectGymIndex(-1);
        gymEntity.searchGymController.clear();
        gymController.onSearchGymValidation();
        if (value == "looking") {
          gymController.getNearByGyms(context, type: "NearByGym");
          gymController.getSubIndustry(context);
          gymController.onSelectedSubIndustryId(context, value: "");
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kPrimaryColor.withValues(alpha: 0.02) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kPrimaryColor.withValues(alpha: 0.8) : const Color(0xFFE3E8EB),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected ? AppColors.kPrimaryColor.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 10 : 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kPrimaryColor : AppColors.kPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.kPrimaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.kPrimaryColor : const Color(0xFF2D3436))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.kPrimaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextButton(String label, {required void Function()? onPressed}) => TextButton(
        style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor)),
        onPressed: onPressed,
        child: Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500, color: AppColors.kPrimaryColor)),
      );
}
