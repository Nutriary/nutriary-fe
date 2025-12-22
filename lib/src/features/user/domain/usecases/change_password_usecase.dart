import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/user_repository.dart';

@lazySingleton
class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  final UserRepository _repository;

  ChangePasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) {
    return _repository.changePassword(params.oldPassword, params.newPassword);
  }
}

class ChangePasswordParams extends Equatable {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordParams(this.oldPassword, this.newPassword);

  @override
  List<Object?> get props => [oldPassword, newPassword];
}
