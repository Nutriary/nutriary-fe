import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

@lazySingleton
class GetProfileUseCase extends UseCase<User, NoParams> {
  final UserRepository repository;
  GetProfileUseCase(this.repository);
  @override
  Future<Either<Failure, User>> call(NoParams params) =>
      repository.getProfile();
}

@lazySingleton
class UpdateFcmTokenUseCase extends UseCase<void, String> {
  final UserRepository repository;
  UpdateFcmTokenUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(String token) =>
      repository.updateFcmToken(token);
}
