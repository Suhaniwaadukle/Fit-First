class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException() : super("No Internet connection. Please try again later.");
}

class TimeoutException extends AppException {
  TimeoutException() : super("Request timed out. Please try again.");
}

class ServerException extends AppException {
  ServerException() : super("Server error. Please try again later.");
}

class UnknownException extends AppException {
  UnknownException() : super("An unexpected error occurred. Please try again.");
}
