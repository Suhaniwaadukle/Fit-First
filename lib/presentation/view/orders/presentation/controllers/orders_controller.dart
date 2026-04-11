// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:orka_sports/app/widgets/common_formatter/common_formatter.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:orka_sports/presentation/view/orders/data/repositories/orders_repo_iml.dart';
import 'package:orka_sports/presentation/view/orders/domain/entities/orders_entity.dart';
import 'package:orka_sports/presentation/view/orders/domain/repositories/orders_repo.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersController extends StateNotifier<OrdersEntity> {
  OrdersController() : super(OrdersEntity.initial());

  final OrdersRepo _ordersRepo = OrdersRepoIml();
  final SharedPreferences prefs = GetItService.getIt<SharedPreferences>();
  final CommonFormatter formatter = CommonFormatter();

  // Function to call all the order details
Future<void> getAllOrders(BuildContext context) async {
  try {
    state = state.copyWith(isAllOrdersLoading: true);
    
    final userId = prefs.getString("userId") ?? "0";
    
    print("🔍 Sending userid as: $userId");
    
    await _ordersRepo.getAllOrdersRepo(userId: userId).then((value) {
      print("🔍 API Response Status: ${value.status}");
      print("🔍 API Response Data: ${value.data}");
      
      log("Success orders list $value");
      state = state.copyWith(getAllOrdersList: value);
    });
  } catch (e) {
    log("orders list error : ${e.toString()}");
    showCustomSnackbar(context, "Something went wrong!", isError: true);
  } finally {
    state = state.copyWith(isAllOrdersLoading: false);
  }
}




}
