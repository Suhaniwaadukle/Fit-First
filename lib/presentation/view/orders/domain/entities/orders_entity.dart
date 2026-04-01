import 'package:flutter/material.dart';
import 'package:orka_sports/presentation/view/orders/data/models/get_allorders_model.dart';

@immutable
class OrdersEntity {
  final bool isAllOrdersLoading;

  final GetAllOrdersModel getAllOrdersList;

  const OrdersEntity({
    required this.isAllOrdersLoading,
    required this.getAllOrdersList,
  });

  factory OrdersEntity.initial() {
    return OrdersEntity(
      isAllOrdersLoading: false,
      getAllOrdersList: GetAllOrdersModel(),
    );
  }

  OrdersEntity copyWith({
    bool? isAllOrdersLoading,
    GetAllOrdersModel? getAllOrdersList,
  }) {
    return OrdersEntity(
      isAllOrdersLoading: isAllOrdersLoading ?? this.isAllOrdersLoading,
      getAllOrdersList: getAllOrdersList ?? this.getAllOrdersList,
    );
  }
}
