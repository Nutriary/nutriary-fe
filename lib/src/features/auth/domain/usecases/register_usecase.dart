import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase extends UseCase<void, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return repository.register(
      params.email,
      params.password,
      params.name,
      params.username,
    );
  }
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
  List<Object> get props => [email, password, name, username];
}
