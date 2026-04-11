import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:orka_sports/presentation/view/body_iq/domain/entities/body_iq_entity.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/controllers/body_iq_controller.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';
import 'package:orka_sports/presentation/view/home/domain/entities/home_entity.dart';
import 'package:orka_sports/presentation/view/home/presentation/controllers/home_controller.dart';
import 'package:orka_sports/presentation/view/orders/domain/entities/orders_entity.dart';
import 'package:orka_sports/presentation/view/orders/presentation/controllers/orders_controller.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/domain/entities/refer_earn_entity.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/presentation/controllers/refer_earn_controller.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/domain/entities/scheduler_entity.dart';
import 'package:orka_sports/presentation/view/scheduler_reminders/presentation/controllers/scheduler_controller.dart';

class DiProviders {
  // Di For BodyIQ
  static final bodyIqControllerProvider = StateNotifierProvider<BodyIqController, BodyIqEntity>((ref) {
    return BodyIqController();
  });
  // Di For BodyIQ
  static final schedulerControllerProvider = StateNotifierProvider<SchedulerController, SchedulerEntity>((ref) {
    return SchedulerController();
  });
  // Di For Gym
  static final gymControllerProvider = StateNotifierProvider<GymController, GymEntity>((ref) {
    return GymController();
  });
  // Di For Refer & Earn
  static final referralControllerProvider = StateNotifierProvider<ReferEarnController, ReferEarnEntity>((ref) {
    return ReferEarnController();
  });
  // Di For Home
  static final homeControllerProvider = StateNotifierProvider<HomeController, HomeEntity>((ref) {
    return HomeController();
  });
  // Di For Orders
  static final ordersControllerProvider = StateNotifierProvider<OrdersController, OrdersEntity>((ref) {
    return OrdersController();
  });
}
