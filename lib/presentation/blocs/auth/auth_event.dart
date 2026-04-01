part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final RegisterRequest request;

  RegisterRequested(this.request);

  @override
  List<Object> get props => [request];
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {
  final String? token;

  AuthCheckRequested(this.token);

  @override
  List<Object> get props => [token ?? ''];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  ForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

// ✅ Google Register Event - Added to Match Your Style
class GoogleRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String googleId;
  final String verifiedEmail;
  final String picture;

  GoogleRegisterRequested({
    required this.name,
    required this.email,
    required this.googleId,
    required this.verifiedEmail,
    required this.picture,
  });

  @override
  List<Object> get props => [name, email, googleId, verifiedEmail, picture];
}
class AppleRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String appleId;
  final String verifiedEmail;

  AppleRegisterRequested({
    required this.name,
    required this.email,
    required this.appleId,
    required this.verifiedEmail,
  });

  @override
  List<Object> get props => [name, email, appleId, verifiedEmail];
}
