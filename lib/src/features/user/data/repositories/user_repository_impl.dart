import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getProfile();
  Future<void> updateFcmToken(String token);
}

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio _dio;
  UserRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> getProfile() async {
    final response = await _dio.get('/user');
    final data = response.data['data'];
    return UserModel.fromJson(data);
  }

  @override
  Future<void> updateFcmToken(String token) async {
    await _dio.put('/user/fcm-token', data: {'token': token});
  }
}

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;
  UserRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final result = await _dataSource.getProfile();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to load profile',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    try {
      await _dataSource.updateFcmToken(token);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to update FCM token',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
