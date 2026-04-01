part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

//! Auth Login
class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object> get props => [message];
}

//! Auth_Registration
class AuthRegistrationLoading extends AuthState {}

class AuthRegistrationSuccess extends AuthState {}

class AuthRegistrationError extends AuthState {
  final String error;

  AuthRegistrationError({required this.error});

  @override
  List<Object> get props => [error];
}

//! Forgot Password
class ForgotPasswordLoading extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class ForgotPasswordError extends AuthState {
  final String error;

  ForgotPasswordError({required this.error});

  @override
  List<Object> get props => [error];
}

//! ✅ Google Register States
class GoogleRegisterLoading extends AuthState {}

class GoogleRegisterSuccess extends AuthState {}

class GoogleRegisterError extends AuthState {
  final String error;

  GoogleRegisterError({required this.error});

  @override
  List<Object> get props => [error];
}
