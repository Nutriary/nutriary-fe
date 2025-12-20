import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

@lazySingleton
class LoginUseCase extends UseCase<String, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  @override
  Future<Either<Failure, String>> call(LoginParams params) =>
      repository.login(params.email, params.password);
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String username;
  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.username,
  });
  @override
  List<Object?> get props => [email, password, name, username];
}

@lazySingleton
class RegisterUseCase extends UseCase<void, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(RegisterParams params) => repository
      .register(params.email, params.password, params.name, params.username);
}
