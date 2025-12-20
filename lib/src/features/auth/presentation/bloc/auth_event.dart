import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  const LoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String username;
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.username,
  });
  @override
  List<Object?> get props => [email, password, name, username];
}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
