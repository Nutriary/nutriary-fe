import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/system_stats.dart';
import '../../../user/domain/entities/user.dart';

abstract class AdminRepository {
  Future<Either<Failure, SystemStats>> getSystemStats();
  Future<Either<Failure, List<User>>> getUsers({int page = 1, int size = 20});
  Future<Either<Failure, void>> updateUserRole(int userId, String role);
  Future<Either<Failure, void>> deleteUser(int userId);
}
