import 'package:flutter/material.dart';

import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_preferences/buddy_status.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_preferences/communication_level.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_preferences/experience_level.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_preferences/fitness_goal.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_preferences/gender_preferences.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/gym_buddy/gym_buddy.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/gym_buddy/gym_buddy_details.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/gym_details.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_selection/gym_selection.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/info_screen/info_screen.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/presentation/pages/body_iq_scheduler/scheduler.dart';
import 'package:orka_sports/presentation/view/splash_screen/splash_screen.dart';

import '../../presentation/view/body_iq/presentation/pages/assessment/assessment_screen.dart';
import '../../presentation/view/scheduler_reminders/presentation/pages/body_iq_scheduler/add_view_scheduler.dart';
import '../../presentation/view/body_iq/presentation/pages/products/product_details.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // App Routes for splash
      case AppRoutesConstants.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      // App Routes for assessment
      case AppRoutesConstants.assessmentRoute:
        return MaterialPageRoute(builder: (_) => const AssessmentScreen());
      // App Routes for product
      case AppRoutesConstants.productDetailsRoute:
        return MaterialPageRoute(builder: (_) => const ProductDetailsScreen());
      // App Routes for scheduler & reminder
      case AppRoutesConstants.schedulerRoute:
        return MaterialPageRoute(builder: (_) => const SchedulerScreen());
      // App Routes for add-view reminder
      case AppRoutesConstants.addViewSchedulerRoute:
        return MaterialPageRoute(builder: (_) => const AddViewSchedulerScreen());
      // App Routes for Gym
      case AppRoutesConstants.basicGymInfo:
        return MaterialPageRoute(builder: (_) => const InfoGymScreen());
      case AppRoutesConstants.fitnessGoal:
        return MaterialPageRoute(builder: (_) => const FitnessGoalsScreen());
      case AppRoutesConstants.expLevel:
        return MaterialPageRoute(builder: (_) => const ExperienceLevelScreen());
      case AppRoutesConstants.communication:
        return MaterialPageRoute(builder: (_) => const CommunicationStyleScreen());
      case AppRoutesConstants.budyyGender:
        return MaterialPageRoute(builder: (_) => const GenderPreferenceScreen());
      case AppRoutesConstants.buddyStatus:
        return MaterialPageRoute(builder: (_) => const BuddyStatusScreen());
      case AppRoutesConstants.gymSelection:
        return MaterialPageRoute(builder: (_) => const GymSelectionScreen());
      case AppRoutesConstants.gymDetails:
        return MaterialPageRoute(builder: (_) => const GymDetailsScreen());
      case AppRoutesConstants.gymBuddy:
        return MaterialPageRoute(builder: (_) => const GymBuddyListingScreen());
      case AppRoutesConstants.gymBuddyDetails:
        return MaterialPageRoute(builder: (_) => const GymBuddyDetails());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
