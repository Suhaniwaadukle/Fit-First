import 'dart:developer';
import 'package:orka_sports/core/utils/error_handling.dart';
import 'package:orka_sports/presentation/view/orders/data/datasources/orders_service.dart';
import 'package:orka_sports/presentation/view/orders/data/models/get_allorders_model.dart';
import 'package:orka_sports/presentation/view/orders/domain/repositories/orders_repo.dart';

class OrdersRepoIml extends OrdersService implements OrdersRepo {
  //Repo function to get all orders
  @override
  Future<GetAllOrdersModel> getAllOrdersRepo({required String userId}) async {
    try {
      final response = await getAllOrdersService(userId: userId);
      GetAllOrdersModel getAllOrdersModel = GetAllOrdersModel.fromJson(response.data);
      return getAllOrdersModel;
    } catch (e) {
      log("error-- : $e}");
      throw ErrorHandler.handleError(e);
    }
  }
}
