import 'package:flutter/material.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/lifestyle_model/get_lifestyle_model.dart';
import '../../data/models/diet_models/meal_recommendations_model.dart'; // ADD THIS IMPORT

import '../../data/models/dosha_models/get_dosha_diet_model.dart';
import '../../data/models/dosha_models/get_dosha_exercise_model.dart';
import '../../data/models/dosha_models/get_dosha_meditation_model.dart';
import '../../data/models/dosha_models/get_dosha_result_model.dart';
import '../../data/models/product_models/get_fullreco_product_model.dart';
import '../../data/models/product_models/get_productby_partner_mode.dart';
import '../../data/models/product_models/get_reco_products_model.dart';

@immutable
class BodyIqEntity {
  final bool isUserInfoLoading;
  final bool isDoshaLoading;
  final bool isDoshaResultLoading;
  final bool isDoshaDietLoading;
  final bool isDoshaMeditationLoading;
  final bool isDoshaExerciseLoading;
  final bool isHealthRiskLoading;
  final bool isUserProfileValid;
  final int currentStep;
  final bool showWelcome;

  // ADD THESE DIET-RELATED PROPERTIES
  final bool isDietLoading;
  final DailyMealData? dailyMealData;
  final String? dietError;
  final bool isAddingFood;

  final Map<String, dynamic> userData;
  final Map<String, int> doshaScores;
  final int lifestyleScore;
  final int riskScore;

  final int currentDoshaQuestion;
  final int currentLifestyleQuestion;
  final int currentRiskQuestion;

  // Dosha quiz state
  final List<String> doshaQuestions;
  final List<List<String>> doshaOptions;
  final Map<int, String> selectedAnswers;
  final Map<int, int> selectedPositions;

  // Lifestyle quiz state
  final List<String> lifeStyleQuestions;
  final List<List<String>> lifeStyleOptions;
  final Map<int, String> selectedLifeStyleAnswers;
  final Map<int, int> selectedLifeStylePositions;

  // Health risk quiz state
  final List<String> healthRiskQuestions;
  final List<List<String>> healthRiskOptions;
  final Map<int, String> selectedHealthRiskAnswers;

  //Add controllers for user input
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;

  //Add dropdown selections
  final TextEditingController genderController;
  final TextEditingController ethnicityController;

  //Add selectable options
  final String selectedGoal;
  final Set<String> selectedHistory;
  final List<String> goals;
  final List<String> familyHistory;
  final List<String> genderList;
  final List<String> ethnicityList;

  final GetDoshaResultModel getDoshaResultModel;
  final GetDoshaRecoDietModel getDoshaRecoDietModel;
  final GetDoshaRecoMeditationModel getDoshaRecoMeditationModel;
  final GetDoshaRecoExerciseModel getDoshaRecoExerciseModel;
  final List<String> dietTitles;
  final bool isRecoProductsLoading;
  final GetRecoProductModel getRecoProductModel;
  final bool isProductsByPartnerLoading;
  final bool isFullRecoProductsLoading;
  final GetProductByPartnerModel getProductByPartnerModel;
  final GetFullRecoProductModel getFullRecoProductModel;
  final TextEditingController phoneNumberController;
  final bool isLifeStyleResultLoading;
  final GetLifeStyleResultModel getLifeStyleResultModel;

  const BodyIqEntity({
    required this.isUserInfoLoading,
    required this.isDoshaLoading,
    required this.isDoshaResultLoading,
    required this.isDoshaDietLoading,
    required this.isDoshaMeditationLoading,
    required this.isDoshaExerciseLoading,
    required this.isHealthRiskLoading,
    required this.isUserProfileValid,
    required this.currentStep,
    required this.showWelcome,
    
    // ADD THESE DIET PARAMETERS
    this.isDietLoading = false,
    this.dailyMealData,
    this.dietError,
    this.isAddingFood = false,
    
    required this.userData,
    required this.doshaScores,
    required this.lifestyleScore,
    required this.riskScore,
    required this.currentDoshaQuestion,
    required this.currentLifestyleQuestion,
    required this.currentRiskQuestion,
    required this.doshaQuestions,
    required this.selectedPositions,
    required this.doshaOptions,
    required this.selectedAnswers,
    required this.lifeStyleQuestions,
    required this.lifeStyleOptions,
    required this.selectedLifeStylePositions,
    required this.selectedLifeStyleAnswers,
    required this.healthRiskQuestions,
    required this.healthRiskOptions,
    required this.selectedHealthRiskAnswers,
    // Controllers
    required this.nameController,
    required this.ageController,
    required this.heightController,
    required this.weightController,

    // Dropdowns
    required this.genderController,
    required this.ethnicityController,

    // Goals and history
    required this.selectedGoal,
    required this.selectedHistory,
    required this.goals,
    required this.familyHistory,
    required this.genderList,
    required this.ethnicityList,
    required this.getDoshaResultModel,
    required this.getDoshaRecoDietModel,
    required this.getDoshaRecoMeditationModel,
    required this.getDoshaRecoExerciseModel,
    required this.dietTitles,
    required this.isRecoProductsLoading,
    required this.getRecoProductModel,
    required this.isProductsByPartnerLoading,
    required this.isFullRecoProductsLoading,
    required this.getProductByPartnerModel,
    required this.getFullRecoProductModel,
    required this.phoneNumberController,
    required this.isLifeStyleResultLoading,
    required this.getLifeStyleResultModel,
  });

  factory BodyIqEntity.initial() {
    return BodyIqEntity(
      isUserInfoLoading: false,
      isDoshaLoading: false,
      isDoshaResultLoading: false,
      isDoshaDietLoading: false,
      isDoshaMeditationLoading: false,
      isDoshaExerciseLoading: false,
      isHealthRiskLoading: false,
      isUserProfileValid: false,
      currentStep: 1,
      showWelcome: true,
      
      // ADD THESE DIET INITIAL VALUES
      isDietLoading: false,
      dailyMealData: null,
      dietError: null,
      isAddingFood: false,
      
      userData: {},
      doshaScores: {'vata': 0, 'pitta': 0, 'kapha': 0},
      lifestyleScore: 0,
      riskScore: 0,
      currentDoshaQuestion: 0,
      selectedPositions: {},
      selectedLifeStylePositions: {},
      currentLifestyleQuestion: 0,
      currentRiskQuestion: 0,
      doshaQuestions: [
        'Body frame?',
        'Skin type?',
        'Appetite?',
        'Energy pattern?',
        'Sleep?',
        'Digestion?',
        'Reaction to stress?',
        'Voice?',
        'Walking style?',
        'Climate preference?',
      ],
      doshaOptions: [
        ['Thin', 'Medium/muscular', 'Large/sturdy'],
        ['Dry', 'Sensitive/oily', 'Thick/smooth'],
        ['Irregular', 'Strong', 'Low'],
        ['Bursts', 'Intense', 'Stable/sluggish'],
        ['Light/disturbed', 'Moderate', 'Deep/long'],
        ['Gassy/variable', 'Acidic', 'Slow'],
        ['Anxiety', 'Anger', 'Withdrawal'],
        ['Fast, dry', 'Clear, loud', 'Deep, slow'],
        ['Quick, light', 'Determined', 'Slow, heavy'],
        ['Warm/humid', 'Cool', 'Dry/warm'],
      ],
      selectedAnswers: {},
      lifeStyleQuestions: [
        'How often do you exercise?',
        'How many steps do you walk per day?',
        'What type of workout do you usually do?',
        'How often do you eat outside?',
        'How regular are your meal timings?',
        'How often do you eat late at night?',
        'How frequently do you have sugar cravings?',
        'What is your stress level?',
        'How many hours do you sleep per day?',
        'How would you rate your sleep quality?',
      ],
      lifeStyleOptions: [
        ['Never', '1–2x/week', 'Daily'],
        ['<3k', '3–7k', '8k+'],
        ['None', 'Walk/Yoga', 'Cardio/Weights'],
        ['Daily', 'Weekly', 'Rarely'],
        ['Irregular', 'Somewhat fixed', 'Consistent'],
        ['Always', 'Sometimes', 'Never'],
        ['Daily', 'Occasionally', 'Rare'],
        ['High', 'Medium', 'Low'],
        ['<5 hrs', '6–7 hrs', '8+ hrs'],
        ['Poor', 'Okay', 'Good'],
      ],
      selectedLifeStyleAnswers: {},
      healthRiskQuestions: [
        'Do you often skip meals?',
        'Do you eat emotionally (stress eating)?',
        'Do you suffer from bloating or gas daily?',
        'Do you have irregular bowel movements?',
        'Have you been diagnosed with thyroid or PCOS?',
        'Have you experienced rapid weight gain in the last 6 months?',
        'Do you feel tired after meals?',
        'Do you feel hungry even after eating?',
        'Do you crave sugar daily?',
        'Is there a family history of obesity or diabetes?',
      ],
      healthRiskOptions: List.generate(10, (_) => ['Yes', 'No']),
      selectedHealthRiskAnswers: {},
      nameController: TextEditingController(),
      ageController: TextEditingController(),
      heightController: TextEditingController(),
      weightController: TextEditingController(),
      genderController: TextEditingController(text: 'Select gender'),
      ethnicityController: TextEditingController(text: 'Select ethnicity'),
      selectedGoal: '',
      selectedHistory: <String>{},
      goals: ['Lose Weight', 'Gain Weight', 'Improve Digestion', 'Balance Hormones', 'Build Immunity'],
      familyHistory: ['Obesity', 'Thyroid', 'Diabetes', 'PCOS', 'None'],
      genderList: ['Male', 'Female', 'Other'],
      ethnicityList: [
        'Asian',
        'Black / African',
        'Caucasian / White',
        'Hispanic / Latino',
        'Middle Eastern',
        'Native American / Indigenous',
        'Pacific Islander',
        'South Asian',
        'Southeast Asian',
        'Mixed / Multiracial',
        'Other'
      ],
      getDoshaResultModel: GetDoshaResultModel(),
      getDoshaRecoDietModel: GetDoshaRecoDietModel(),
      getDoshaRecoMeditationModel: GetDoshaRecoMeditationModel(),
      getDoshaRecoExerciseModel: GetDoshaRecoExerciseModel(),
      dietTitles: ["Breakfast", "Lunch", "Dinner"],
      isRecoProductsLoading: false,
      getRecoProductModel: GetRecoProductModel(),
      isProductsByPartnerLoading: false,
      isFullRecoProductsLoading: false,
      getProductByPartnerModel: GetProductByPartnerModel(),
      getFullRecoProductModel: GetFullRecoProductModel(),
      phoneNumberController: TextEditingController(),
      isLifeStyleResultLoading: false,
      getLifeStyleResultModel: GetLifeStyleResultModel(),
    );
  }

  BodyIqEntity copyWith({
    bool? isUserInfoLoading,
    bool? isDoshaLoading,
    bool? isDoshaResultLoading,
    bool? isDoshaDietLoading,
    bool? isDoshaMeditationLoading,
    bool? isDoshaExerciseLoading,
    bool? isHealthRiskLoading,
    bool? isUserProfileValid,
    int? currentStep,
    bool? showWelcome,
    
    // ADD THESE DIET PARAMETERS
    bool? isDietLoading,
    DailyMealData? dailyMealData,
    String? dietError,
    bool? isAddingFood,
    
    Map<String, dynamic>? userData,
    Map<String, int>? doshaScores,
    int? lifestyleScore,
    int? riskScore,
    int? currentDoshaQuestion,
    Map<int, int>? selectedPositions,
    Map<int, int>? selectedLifeStylePositions,
    int? currentLifestyleQuestion,
    int? currentRiskQuestion,
    List<String>? doshaQuestions,
    List<List<String>>? doshaOptions,
    Map<int, String>? selectedAnswers,
    List<String>? lifeStyleQuestions,
    List<List<String>>? lifeStyleOptions,
    Map<int, String>? selectedLifeStyleAnswers,
    List<String>? healthRiskQuestions,
    List<List<String>>? healthRiskOptions,
    Map<int, String>? selectedHealthRiskAnswers,
    //Add controllers for user input
    TextEditingController? nameController,
    TextEditingController? ageController,
    TextEditingController? heightController,
    TextEditingController? weightController,

    //Add dropdown selections
    TextEditingController? genderController,
    TextEditingController? ethnicityController,

    //Add selectable options
    String? selectedGoal,
    Set<String>? selectedHistory,
    List<String>? goals,
    List<String>? familyHistory,
    List<String>? genderList,
    List<String>? ethnicityList,
    GetDoshaResultModel? getDoshaResultModel,
    GetDoshaRecoDietModel? getDoshaRecoDietModel,
    GetDoshaRecoMeditationModel? getDoshaRecoMeditationModel,
    GetDoshaRecoExerciseModel? getDoshaRecoExerciseModel,
    List<String>? dietTitles,
    bool? isRecoProductsLoading,
    GetRecoProductModel? getRecoProductModel,
    bool? isProductsByPartnerLoading,
    bool? isFullRecoProductsLoading,
    GetProductByPartnerModel? getProductByPartnerModel,
    GetFullRecoProductModel? getFullRecoProductModel,
    TextEditingController? phoneNumberController,
    bool? isLifeStyleResultLoading,
    GetLifeStyleResultModel? getLifeStyleResultModel,
  }) {
    return BodyIqEntity(
      isUserInfoLoading: isUserInfoLoading ?? this.isUserInfoLoading,
      isDoshaLoading: isDoshaLoading ?? this.isDoshaLoading,
      isDoshaResultLoading: isDoshaResultLoading ?? this.isDoshaResultLoading,
      isDoshaDietLoading: isDoshaDietLoading ?? this.isDoshaDietLoading,
      isDoshaMeditationLoading: isDoshaMeditationLoading ?? this.isDoshaMeditationLoading,
      isDoshaExerciseLoading: isDoshaExerciseLoading ?? this.isDoshaExerciseLoading,
      isHealthRiskLoading: isHealthRiskLoading ?? this.isHealthRiskLoading,
      isUserProfileValid: isUserProfileValid ?? this.isUserProfileValid,
      currentStep: currentStep ?? this.currentStep,
      showWelcome: showWelcome ?? this.showWelcome,
      
      // ADD THESE DIET ASSIGNMENTS
      isDietLoading: isDietLoading ?? this.isDietLoading,
      dailyMealData: dailyMealData ?? this.dailyMealData,
      dietError: dietError ?? this.dietError,
      isAddingFood: isAddingFood ?? this.isAddingFood,
      
      userData: userData ?? this.userData,
      doshaScores: doshaScores ?? this.doshaScores,
      lifestyleScore: lifestyleScore ?? this.lifestyleScore,
      riskScore: riskScore ?? this.riskScore,
      currentDoshaQuestion: currentDoshaQuestion ?? this.currentDoshaQuestion,
      selectedPositions: selectedPositions ?? this.selectedPositions,
      currentLifestyleQuestion: currentLifestyleQuestion ?? this.currentLifestyleQuestion,
      currentRiskQuestion: currentRiskQuestion ?? this.currentRiskQuestion,
      doshaQuestions: doshaQuestions ?? this.doshaQuestions,
      doshaOptions: doshaOptions ?? this.doshaOptions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      lifeStyleQuestions: lifeStyleQuestions ?? this.lifeStyleQuestions,
      selectedLifeStylePositions: selectedLifeStylePositions ?? this.selectedLifeStylePositions,
      lifeStyleOptions: lifeStyleOptions ?? this.lifeStyleOptions,
      selectedLifeStyleAnswers: selectedLifeStyleAnswers ?? this.selectedLifeStyleAnswers,
      healthRiskQuestions: healthRiskQuestions ?? this.healthRiskQuestions,
      healthRiskOptions: healthRiskOptions ?? this.healthRiskOptions,
      selectedHealthRiskAnswers: selectedHealthRiskAnswers ?? this.selectedHealthRiskAnswers,
      nameController: nameController ?? this.nameController,
      ageController: ageController ?? this.ageController,
      heightController: heightController ?? this.heightController,
      weightController: weightController ?? this.weightController,
      genderController: genderController ?? this.genderController,
      ethnicityController: ethnicityController ?? this.ethnicityController,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedHistory: selectedHistory ?? this.selectedHistory,
      goals: goals ?? this.goals,
      familyHistory: familyHistory ?? this.familyHistory,
      genderList: genderList ?? this.genderList,
      ethnicityList: ethnicityList ?? this.ethnicityList,
      getDoshaResultModel: getDoshaResultModel ?? this.getDoshaResultModel,
      getDoshaRecoDietModel: getDoshaRecoDietModel ?? this.getDoshaRecoDietModel,
      getDoshaRecoMeditationModel: getDoshaRecoMeditationModel ?? this.getDoshaRecoMeditationModel,
      getDoshaRecoExerciseModel: getDoshaRecoExerciseModel ?? this.getDoshaRecoExerciseModel,
      dietTitles: dietTitles ?? this.dietTitles,
      isRecoProductsLoading: isRecoProductsLoading ?? this.isRecoProductsLoading,
      getRecoProductModel: getRecoProductModel ?? this.getRecoProductModel,
      isProductsByPartnerLoading: isProductsByPartnerLoading ?? this.isProductsByPartnerLoading,
      isFullRecoProductsLoading: isFullRecoProductsLoading ?? this.isFullRecoProductsLoading,
      getProductByPartnerModel: getProductByPartnerModel ?? this.getProductByPartnerModel,
      getFullRecoProductModel: getFullRecoProductModel ?? this.getFullRecoProductModel,
      phoneNumberController: phoneNumberController ?? this.phoneNumberController,
      isLifeStyleResultLoading: isLifeStyleResultLoading ?? this.isLifeStyleResultLoading,
      getLifeStyleResultModel: getLifeStyleResultModel ?? this.getLifeStyleResultModel,
    );
  }
}
