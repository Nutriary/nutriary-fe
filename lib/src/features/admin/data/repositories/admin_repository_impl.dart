import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/system_stats.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../../../user/domain/entities/user.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, SystemStats>> getSystemStats() async {
    try {
      final stats = await remoteDataSource.getSystemStats();
      return Right(stats);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch admin stats',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsers({
    int page = 1,
    int size = 20,
  }) async {
    try {
      final users = await remoteDataSource.getUsers(page, size);
      return Right(users);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch users'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole(int userId, String role) async {
    try {
      await remoteDataSource.updateUserRole(userId, role);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update role'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int userId) async {
    try {
      await remoteDataSource.deleteUser(userId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete user'));
    }
  }
}
