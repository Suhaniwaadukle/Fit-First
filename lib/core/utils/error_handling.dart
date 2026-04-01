import 'dart:io';
import 'package:orka_sports/core/utils/app_exception.dart';

class ErrorHandler {
  static AppException handleError(dynamic error) {
    if (error is SocketException) {
      return NetworkException();
    } else if (error is TimeoutException) {
      return TimeoutException();
    } else if (error is HttpException) {
      return ServerException();
    } else {
      return UnknownException();
    }
  }
}
