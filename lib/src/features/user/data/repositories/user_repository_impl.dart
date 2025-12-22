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
  Future<UserModel> updateUser(String? username, {String? imagePath});
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> deleteAccount();
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

  @override
  Future<UserModel> updateUser(String? username, {String? imagePath}) async {
    final formData = FormData();
    if (username != null) {
      formData.fields.add(MapEntry('username', username));
    }
    if (imagePath != null) {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(imagePath)),
      );
    }

    final response = await _dio.put('/user', data: formData);
    final data = response.data['data'];
    return UserModel.fromJson(data);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.post(
      '/user/change-password',
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  @override
  Future<void> deleteAccount() async {
    await _dio.delete('/user');
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

  @override
  Future<Either<Failure, User>> updateUser(
    String? username, {
    String? imagePath,
  }) async {
    try {
      final result = await _dataSource.updateUser(
        username,
        imagePath: imagePath,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to update profile',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      await _dataSource.changePassword(oldPassword, newPassword);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to change password',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _dataSource.deleteAccount();
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to delete account',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
