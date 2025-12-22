import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, void>> updateFcmToken(String token);
  Future<Either<Failure, User>> updateUser(
    String? username, {
    String? imagePath,
  });
  Future<Either<Failure, void>> changePassword(
    String oldPassword,
    String newPassword,
  );
  Future<Either<Failure, void>> deleteAccount();
}
