import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final String? token;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, token];
}
