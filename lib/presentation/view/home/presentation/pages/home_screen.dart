import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:orka_sports/presentation/view/home/data/repositories/home_repo_impl.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/all_coaches_screen.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/all_partners_screen.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/coach_details_screen.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/partner_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/presentation/view/home/presentation/controllers/home_controller.dart';
import 'package:orka_sports/presentation/view/home/domain/entities/home_entity.dart';
import 'package:orka_sports/presentation/view/home/data/models/get_allpartners_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CoachModel {
  final String id;
  final String userId;
  final String fullName;
  final String profilePhoto;
  final String dob;
  final String gender;
  final String country;
  final String state;
  final String city;
  final String address;
  final String contactNumber;
  final String altNumber;
  final String email;
  final String distance;
  final String? industry;
  final String? subIndustry;
  final String coachImageBase;
  final String? openToOnline;
  
  CoachModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.profilePhoto,
    required this.dob,
    required this.gender,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.contactNumber,
    required this.altNumber,
    required this.email,
    required this.distance,
    this.industry,
    this.subIndustry,
    required this.coachImageBase,
    this.openToOnline,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Unknown Coach',
      profilePhoto: json['profile_photo']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      altNumber: json['alt_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
      industry: json['industry']?.toString(),
      subIndustry: json['sub_industry']?.toString(),
      coachImageBase: json['coach_image']?.toString() ?? '',
      openToOnline: json['open_to_online']?.toString(),
    );
  }

  String get fullImageUrl {
    if (coachImageBase.isNotEmpty) {
      return coachImageBase;
    }
    if (profilePhoto.isNotEmpty && coachImageBase.isNotEmpty) {
      return coachImageBase + profilePhoto;
    }
    return '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'dob': dob,
      'gender': gender,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'contact_number': contactNumber,
      'alt_number': altNumber,
      'email': email,
      'industry': industry,
      'sub_industry': subIndustry,
      'distance': distance,
      'coach_image': coachImageBase,
      'open_to_online': openToOnline,
    };
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeEntity>((ref) {
  return HomeController();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  String selectedLevel = 'All';
  bool isLoading = false;
  bool isCoachesLoading = false;
  late AnimationController fadeController;
  late AnimationController slideController;

  List<CoachModel> allCoaches = [];
  List<CoachModel> filteredCoaches = [];
  final List<String> levels = ['All', 'Gym', 'Yoga', 'Zumba'];

  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addObserver(this);
    
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    fadeController.forward();
    slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  super.didChangeAppLifecycleState(state);
  
  if (state == AppLifecycleState.resumed) {
    debugPrint('🔄 App resumed - resetting and refreshing partners data...');

    ref.invalidate(homeControllerProvider);

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        ref.read(homeControllerProvider.notifier).getAllPartnersHome(context);
      }
    });
  }
}

  Future<void> loadInitialData() async {
    debugPrint('🚀 Loading initial data...');
    
    try {
      await Future.wait([
        loadCoachesFromAPI(),
        ref.read(homeControllerProvider.notifier).getAllPartnersHome(context),
      ]);
      
      debugPrint('✅ Initial data loaded successfully');
      updateUserLocation();
      
    } catch (e) {
      debugPrint('❌ Error loading initial data: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load data. Pull to refresh.'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => loadInitialData(),
            ),
          ),
        );
      }
    }
  }

  Future<void> updateUserLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("userId");
      
      if (userId == null || userId.isEmpty) {
        debugPrint('No user ID found for location update');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        
        Position position = await Geolocator.getCurrentPosition();

        http.post(
          Uri.parse('https://fitfirst.online/Api/updateUserLocation'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'user_id': int.parse(userId),
            'latitude': position.latitude.toString(),
            'longitude': position.longitude.toString(),
          }),
        ).then((response) {
          if (response.statusCode == 200) {
            debugPrint('✅ Location updated: ${position.latitude}, ${position.longitude}');
          } else {
            debugPrint('❌ Location update failed: ${response.statusCode}');
          }
        }).catchError((error) {
          debugPrint('❌ Location update error: $error');
        });
      }
      
    } catch (e) {
      debugPrint('Location update exception: $e');
    }
  }

  Future<void> loadCoachesFromAPI() async {
    setState(() {
      isCoachesLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString("userId");
      
      if (userId == null || userId.isEmpty) {
        debugPrint('No user ID found in SharedPreferences');
        return;
      }

      // ✅ Include type parameter in request
      final response = await http.post(
        Uri.parse('https://fitfirst.online/Api/getcoaches'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'userid': userId,
          'type': selectedLevel.toLowerCase(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          final List<dynamic> coachesJson = data['data'] ?? [];
          if (mounted) {
            setState(() {
              allCoaches = coachesJson.map((json) => CoachModel.fromJson(json)).toList();
              filteredCoaches = allCoaches;
            });
          }
        } else {
          debugPrint('API Error: ${data['message']}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading coaches: $e');
    } finally {
      if (mounted) {
        setState(() {
          isCoachesLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    fadeController.dispose();
    slideController.dispose();
    super.dispose();
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

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: refreshData,
          color: AppColors.kPrimaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              buildEnhancedCoachesSection(),
              buildAdsSection(),
              buildEnhancedPartnersSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEnhancedCoachesSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coaches',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Expert trainers ready to help you',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.kPrimaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllCoachesScreen(
                            coaches: allCoaches,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 130,
            margin: const EdgeInsets.only(bottom: 16),
            child: isCoachesLoading 
                ? buildCoachesLoading()
                : buildCoachesSuccess(),
          ),

          Container(
            height: 45,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final isSelected = level == selectedLevel;
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Material(
                    borderRadius: BorderRadius.circular(25),
                    elevation: isSelected ? 4 : 0,
                    shadowColor: AppColors.kPrimaryColor.withOpacity(0.3),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        setState(() {
                          selectedLevel = level;
                        });
                        loadCoachesFromAPI();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? LinearGradient(
                                  colors: [
                                    AppColors.kPrimaryColor,
                                    AppColors.kPrimaryColor.withOpacity(0.8),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.transparent 
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCoachesLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.kPrimaryColor),
          const SizedBox(height: 8),
          Text(
            'Loading coaches...',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget buildCoachesSuccess() {
    if (filteredCoaches.isEmpty) {
      return Center(
        child: Text(
          'No coaches found',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final displayCoaches = filteredCoaches.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 32;
        final cardWidth = (availableWidth - 32) / 3;
        
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayCoaches.length,
          itemBuilder: (context, index) {
            final coach = displayCoaches[index];
            return Container(
              width: cardWidth,
              margin: EdgeInsets.only(right: index < displayCoaches.length - 1 ? 16 : 0),
              child: buildSimplifiedCoachCard(coach, index),
            );
          },
        );
      },
    );
  }

  Widget buildSimplifiedCoachCard(CoachModel coach, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoachDetailsScreen(
                      coach: coach.toMap(),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ High-Quality Coach Image
                    Container(
                      height: 94,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: coach.coachImageBase.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: coach.coachImageBase,
                                fit: BoxFit.cover,
                                height: 94,
                                width: double.infinity,
                                filterQuality: FilterQuality.high,
                                placeholder: (context, url) => Container(
                                  height: 94,
                                  color: Colors.grey[100],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.kPrimaryColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 94,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                fadeInDuration: const Duration(milliseconds: 200),
                                fadeOutDuration: const Duration(milliseconds: 200),
                              )
                            : Container(
                                height: 94,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                    ),
                    
                    // Coach Name
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            coach.fullName.split(' ').first,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildAdsSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.kPrimaryColor,
              AppColors.kPrimaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimaryColor.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.campaign,
                  size: 24,
                  color: AppColors.kPrimaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Partner with Fit First. Power your business.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => launchURL('https://fitfirst.online'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'fitfirst.online',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget buildEnhancedPartnersSection() {
    return SliverToBoxAdapter(
      child: Container(
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
                        'Partners Near You',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        'Premium fitness locations',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange,
                          Colors.orange.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        final homeState = ref.read(homeControllerProvider);
                        final partnersData = homeState.getAllPartnersList?.data ?? [];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllPartnersScreen(
                              partners: partnersData,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            buildPartnersContentDirect(),
          ],
        ),
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
                  onPressed: () => setState(() {}), // ✅ Rebuild to retry
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      
      // Success state
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
                  onPressed: () => setState(() {}), // ✅ Rebuild to retry
                  child: const Text('Search Again'),
                ),
              ],
            ),
          ),
        );
      }
      
      // Show partners
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

Future<GetAllPartnersModel> _loadPartnersDirectly() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString("userId");
  
  if (userId == null || userId.isEmpty) {
    throw Exception('No user ID found');
  }
  
  // ✅ Create the repository directly (same as HomeController does)
  final homeRepoImpl = HomeRepoImpl();
  
  return await homeRepoImpl.getAllPartnersRepo(data: {
    "user_id": userId,
  });
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

  Future<void> refreshData() async {
    debugPrint('🔄 Starting refresh...');
    
    setState(() {
      isLoading = true;
    });
    
    try {
      await Future.wait([
        loadCoachesFromAPI(),
        ref.read(homeControllerProvider.notifier).getAllPartnersHome(context),
      ]);
      
      debugPrint('✅ Refresh completed successfully');
    } catch (e) {
      debugPrint('❌ Refresh error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

class Partner {
  final String id;
  final String name;
  final String type;
  final String specialization;
  final double rating;
  final double distance;
  final String imageUrl;
  final String level;
  final int price;
  final bool isOnline;
  final String? address;
  final bool? isNew;
  final String? hours;
  final String? experience;
  final int? sessions;
  final List<String>? amenities;
  final List<Map<String, dynamic>>? productsAndServices;

  Partner({
    required this.id,
    required this.name,
    required this.type,
    required this.specialization,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.level,
    required this.price,
    required this.isOnline,
    this.address,
    this.isNew,
    this.hours,
    this.experience,
    this.sessions,
    this.amenities,
    this.productsAndServices,
  });
}
