import 'package:flutter/material.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_coaches_details_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_coaches_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_gym_buddy.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_gym_buddy_details_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_near_gym_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_sub_industry_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/gym_details_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/search_gym_model.dart';
import 'package:orka_sports/presentation/view/gym/data/models/selectable_tile_model.dart';
// ✅ ADD THIS IMPORT
import 'package:orka_sports/presentation/view/gym/data/models/gym_food_models.dart';


@immutable
class GymEntity {
  // ✅ ALL EXISTING PROPERTIES
  final bool isPreferrencesLoading;
  final TextEditingController fitnessController;
  final TextEditingController expController;
  final TextEditingController communicationController;
  final TextEditingController buddyGenderController;
  final TextEditingController buddyStatusController;
  final List<SelectableTileItem> selectedItems;
  final bool isSearchGymLoading;
  final TextEditingController searchGymController;
  final SearchGymModel searchGymList;
  final String selectedMembershipOption;
  final int selectedGymIndex;
  final bool isSearchFieldValid;
  final bool isNearGymLoading;
  final GetNearGymModel getNearGymsList;
  final bool isGymDetailsLoading;
  final GetGymDetailsModel getGymDetailsList;
  final bool isGymBuddyLoading;
  final bool isGymBuddyDetailsLoading;
  final GetGymBuddyModel getGymBuddyList;
  final GetGymBuddyDetailsModel getGymBuddyDetailsList;
  final String selectedExperience;
  final List<GymBuddyData>? getBuddyDataList;
  final bool isRequestBuddyLoading;
  final bool isVerifyCodeLoading;
  final TextEditingController gymCodeController;
  final bool isVerifyCode;
  final bool isGymCodeVerified;  // 🆕 NEW FIELD
  final bool isSubIndustryLoading;
  final GetSubIndustryModel getSubIndustryList;
  final String selectedSubIndustryId;
  final bool isRequestGymLoading;
  final bool isCoachesListLoading;
  final bool isCoachesDetailsLoading;
  final GetCoachesListModel getCoachesList;
  final GetCoachesDetailsModel getCoachesDetails;
  final bool isShowAllCoaches;
  
  // ✅ NEW PROPERTIES FOR GYM FOOD
  final bool isGymFoodLoading;
  final GymMealRecommendationsResponse? currentGymRecommendations;


  const GymEntity({
    required this.isPreferrencesLoading,
    required this.fitnessController,
    required this.expController,
    required this.communicationController,
    required this.buddyGenderController,
    required this.buddyStatusController,
    required this.selectedItems,
    required this.isSearchGymLoading,
    required this.searchGymController,
    required this.searchGymList,
    required this.selectedMembershipOption,
    required this.selectedGymIndex,
    required this.isSearchFieldValid,
    required this.isNearGymLoading,
    required this.getNearGymsList,
    required this.isGymDetailsLoading,
    required this.getGymDetailsList,
    required this.isGymBuddyLoading,
    required this.isGymBuddyDetailsLoading,
    required this.getGymBuddyList,
    required this.getGymBuddyDetailsList,
    required this.selectedExperience,
    required this.getBuddyDataList,
    required this.isRequestBuddyLoading,
    required this.isVerifyCodeLoading,
    required this.gymCodeController,
    required this.isVerifyCode,
    required this.isGymCodeVerified,  // 🆕 NEW PARAMETER
    required this.isSubIndustryLoading,
    required this.getSubIndustryList,
    required this.selectedSubIndustryId,
    required this.isRequestGymLoading,
    required this.isCoachesListLoading,
    required this.isCoachesDetailsLoading,
    required this.getCoachesList,
    required this.getCoachesDetails,
    required this.isShowAllCoaches,
    // ✅ NEW PARAMETERS
    required this.isGymFoodLoading,
    this.currentGymRecommendations,
  });


  factory GymEntity.initial() {
    return GymEntity(
      isPreferrencesLoading: false,
      fitnessController: TextEditingController(),
      expController: TextEditingController(),
      communicationController: TextEditingController(),
      buddyGenderController: TextEditingController(),
      buddyStatusController: TextEditingController(),
      selectedItems: [],
      isSearchGymLoading: false,
      searchGymController: TextEditingController(),
      searchGymList: SearchGymModel(),
      selectedMembershipOption: '',
      selectedGymIndex: -1,
      isSearchFieldValid: false,
      isNearGymLoading: false,
      getNearGymsList: GetNearGymModel(),
      isGymDetailsLoading: false,
      getGymDetailsList: GetGymDetailsModel(),
      isGymBuddyLoading: false,
      isGymBuddyDetailsLoading: false,
      getGymBuddyList: GetGymBuddyModel(),
      getGymBuddyDetailsList: GetGymBuddyDetailsModel(),
      selectedExperience: 'All',
      getBuddyDataList: [],
      isRequestBuddyLoading: false,
      isVerifyCodeLoading: false,
      gymCodeController: TextEditingController(),
      isVerifyCode: false,
      isGymCodeVerified: false,  // 🆕 NEW INITIAL VALUE
      isSubIndustryLoading: false,
      getSubIndustryList: GetSubIndustryModel(),
      selectedSubIndustryId: "",
      isRequestGymLoading: false,
      isCoachesListLoading: false,
      isCoachesDetailsLoading: false,
      getCoachesList: GetCoachesListModel(),
      getCoachesDetails: GetCoachesDetailsModel(),
      isShowAllCoaches: false,
      // ✅ NEW INITIAL VALUES
      isGymFoodLoading: false,
      currentGymRecommendations: null,
    );
  }


  GymEntity copyWith({
    bool? isPreferrencesLoading,
    TextEditingController? fitnessController,
    TextEditingController? expController,
    TextEditingController? communicationController,
    TextEditingController? buddyGenderController,
    TextEditingController? buddyStatusController,
    List<SelectableTileItem>? selectedItems,
    bool? isSearchGymLoading,
    TextEditingController? searchGymController,
    SearchGymModel? searchGymList,
    String? selectedMembershipOption,
    int? selectedGymIndex,
    bool? isSearchFieldValid,
    bool? isNearGymLoading,
    GetNearGymModel? getNearGymsList,
    bool? isGymDetailsLoading,
    GetGymDetailsModel? getGymDetailsList,
    bool? isGymBuddyLoading,
    bool? isGymBuddyDetailsLoading,
    GetGymBuddyModel? getGymBuddyList,
    GetGymBuddyDetailsModel? getGymBuddyDetailsList,
    String? selectedExperience,
    List<GymBuddyData>? getBuddyDataList,
    bool? isRequestBuddyLoading,
    bool? isVerifyCodeLoading,
    TextEditingController? gymCodeController,
    bool? isVerifyCode,
    bool? isGymCodeVerified,  // 🆕 NEW PARAMETER
    bool? isSubIndustryLoading,
    GetSubIndustryModel? getSubIndustryList,
    String? selectedSubIndustryId,
    bool? isRequestGymLoading,
    bool? isCoachesListLoading,
    bool? isCoachesDetailsLoading,
    GetCoachesListModel? getCoachesList,
    GetCoachesDetailsModel? getCoachesDetails,
    bool? isShowAllCoaches,
    // ✅ NEW PARAMETERS
    bool? isGymFoodLoading,
    GymMealRecommendationsResponse? currentGymRecommendations,
  }) {
    return GymEntity(
      isPreferrencesLoading: isPreferrencesLoading ?? this.isPreferrencesLoading,
      fitnessController: fitnessController ?? this.fitnessController,
      expController: expController ?? this.expController,
      communicationController: communicationController ?? this.communicationController,
      buddyGenderController: buddyGenderController ?? this.buddyGenderController,
      buddyStatusController: buddyStatusController ?? this.buddyStatusController,
      selectedItems: selectedItems ?? this.selectedItems,
      isSearchGymLoading: isSearchGymLoading ?? this.isSearchGymLoading,
      searchGymController: searchGymController ?? this.searchGymController,
      searchGymList: searchGymList ?? this.searchGymList,
      selectedMembershipOption: selectedMembershipOption ?? this.selectedMembershipOption,
      selectedGymIndex: selectedGymIndex ?? this.selectedGymIndex,
      isSearchFieldValid: isSearchFieldValid ?? this.isSearchFieldValid,
      isNearGymLoading: isNearGymLoading ?? this.isNearGymLoading,
      getNearGymsList: getNearGymsList ?? this.getNearGymsList,
      isGymDetailsLoading: isGymDetailsLoading ?? this.isGymDetailsLoading,
      getGymDetailsList: getGymDetailsList ?? this.getGymDetailsList,
      isGymBuddyLoading: isGymBuddyLoading ?? this.isGymBuddyLoading,
      isGymBuddyDetailsLoading: isGymBuddyDetailsLoading ?? this.isGymBuddyDetailsLoading,
      getGymBuddyList: getGymBuddyList ?? this.getGymBuddyList,
      getGymBuddyDetailsList: getGymBuddyDetailsList ?? this.getGymBuddyDetailsList,
      selectedExperience: selectedExperience ?? this.selectedExperience,
      getBuddyDataList: getBuddyDataList ?? this.getBuddyDataList,
      isRequestBuddyLoading: isRequestBuddyLoading ?? this.isRequestBuddyLoading,
      isVerifyCodeLoading: isVerifyCodeLoading ?? this.isVerifyCodeLoading,
      gymCodeController: gymCodeController ?? this.gymCodeController,
      isVerifyCode: isVerifyCode ?? this.isVerifyCode,
      isGymCodeVerified: isGymCodeVerified ?? this.isGymCodeVerified,  // 🆕 NEW ASSIGNMENT
      isSubIndustryLoading: isSubIndustryLoading ?? this.isSubIndustryLoading,
      getSubIndustryList: getSubIndustryList ?? this.getSubIndustryList,
      selectedSubIndustryId: selectedSubIndustryId ?? this.selectedSubIndustryId,
      isRequestGymLoading: isRequestGymLoading ?? this.isRequestGymLoading,
      isCoachesListLoading: isCoachesListLoading ?? this.isCoachesListLoading,
      isCoachesDetailsLoading: isCoachesDetailsLoading ?? this.isCoachesDetailsLoading,
      getCoachesList: getCoachesList ?? this.getCoachesList,
      getCoachesDetails: getCoachesDetails ?? this.getCoachesDetails,
      isShowAllCoaches: isShowAllCoaches ?? this.isShowAllCoaches,
      // ✅ NEW ASSIGNMENTS
      isGymFoodLoading: isGymFoodLoading ?? this.isGymFoodLoading,
      currentGymRecommendations: currentGymRecommendations ?? this.currentGymRecommendations,
    );
  }
}
