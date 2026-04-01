import 'package:dio/dio.dart';
import 'package:orka_sports/presentation/view/orders/data/models/get_allorders_model.dart';

abstract class OrdersRepo {
  // Repo function to get all orders
  Future<GetAllOrdersModel> getAllOrdersRepo({required String userId});
}
