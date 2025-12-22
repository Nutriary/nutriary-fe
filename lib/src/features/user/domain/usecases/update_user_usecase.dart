import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@lazySingleton
class UpdateUserUseCase implements UseCase<User, UpdateUserParams> {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserParams params) {
    return _repository.updateUser(params.username, imagePath: params.imagePath);
  }
}

class UpdateUserParams extends Equatable {
  final String? username;
  final String? imagePath;

  const UpdateUserParams({this.username, this.imagePath});

  @override
  List<Object?> get props => [username, imagePath];
}
