import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, void>> updateFcmToken(String token);
}
