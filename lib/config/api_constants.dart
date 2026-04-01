class ApiConstants {
  // Api Base URL
  static const apiBaseUrl = 'https://fitfirst.online/Api';

  //BodyIQ Constants
  static const userInfoProfile = '/userProfileUpdate';
  static const insertDoshaQuiz = '/submitDoshaQuiz';
  static const insertLifestyleQuiz = '/submitLifestyleQuiz';
  static const insertHealthRiskQuiz = '/submitWeightRiskQuiz';
  static const getDoshaResult = '/getDominantDosha';
  static const getLifeStyleResult = '/getLifestyleScoreSummary';
  static const getDoshaRecoDiet = '/getDoshaRecommendationDiet';
  static const getDoshaRecoMeditation = '/getDoshaRecommendationMeditation';
  static const getDoshaRecoExercise = '/getDoshaRecommendationExercise';
  static const getRecoProducts = '/getRecommendedProducts';
  static const getRecoProductsByPartner = '/getRecommendedPartnerByProduct';
  static const getFullRecoProducts = '/getFullRecommendedProducts';

  //Daily Reminders Constants
  static const saveDailySchedule = '/saveDailySchedule';
  static const saveMealSchedule = '/saveMealSchedule';
  static const saveSuppliments = '/saveSupplements';
  static const saveReminders = '/saveReminders';
  static const getFullScheduleByDay = '/getFullScheduleByDay';
  static const saveWeeklySchedule = '/saveWeeklySchedule';
  static const getTodayWorkOutSchedule = '/getTodayWorkoutSchedule';
  static const getWeeklyProgress = '/getWeeklyProgress';

  //Gym Management Constants
  static const getGymGoals = '/getGoalForGym';
  static const searchGym = '/searchGym';
  static const getNearGym = '/findNearPartnerGym';
  static const getGymDetails = '/getGymDetails';
  static const getGymBuddy = '/getGymBuddyList';
  static const getGymBuddyDetails = '/getGymBuddyDetails';
  static const getGymBuddyRequest = '/requestGymBuddy';
  static const verifyGymCode = '/verifyGymCode';
  static const getSubIndustry = '/getSubIndustry';
  static const getNearGymByType = '/findNearPartnerGymByType';
  static const requestGymPartner = '/requestGymPartner';
  static const getCoachesList = '/getCoachesByPartner';
  static const getCoachesDetails = '/getCoachDetails';

  //ReferralCode Constants
  static const getReferralDashboard = '/getReferralDashboard';

  //Home Constants
  static const getAllUsers = '/getalluser';
  static const getAllPartners = '/getAllPartnersForUser';

  //Orders Constants
  static const getAllOrders = '/getOrderDetails';


 // Diet Tracking APIs 
  static const getFoodItemsByMealAndDosha = '/getFoodItemsByMealAndDosha';
  static const addFoodItemToMeal = '/addFoodItemToMeal';
}
