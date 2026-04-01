import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:orka_sports/config/api_constants.dart';
import 'package:orka_sports/core/resources/api_interceptor.dart';

abstract class OrdersService {
  final Dio dio = ApiInterceptor().dio;

  //Service function for getting all the users
  Future<Response<dynamic>> getAllOrdersService({required String userId}) {
    final referral = dio.post(
      ApiConstants.getAllOrders,
      data: {
        "userid": int.tryParse(userId) ?? 0, // Send as JSON
      },
    );
    return referral;
  }

  Future<bool> updateOrderStatus({
  required String userId,
  required String orderId,
  required String status,
}) async {
  final uri = Uri.parse('https://fitfirst.online/Api/updateOrderStatus');

  try {
    final response = await http.post(
      uri,
      body: {
        'userid': userId,
        'order_id': orderId,
        'status': status,
      },
    );

    if (response.statusCode == 200) {
      // Check response body for success/error message if needed
      return true;
    } else {
      print('Failed to update order status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error updating order status: $e');
    return false;
  }
}
}
