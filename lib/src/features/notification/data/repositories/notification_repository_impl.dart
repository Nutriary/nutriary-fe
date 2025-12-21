import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(int id);
  Future<void> markAllRead();
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;
  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get('/notification');
    final data = (response.data['data'] as List?) ?? [];
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<void> markAsRead(int id) async {
    await _dio.put('/notification/$id/read');
  }

  @override
  Future<void> markAllRead() async {
    await _dio.put('/notification/read-all');
  }
}

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;
  NotificationRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final result = await _dataSource.getNotifications();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to load notifications',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int id) async {
    try {
      await _dataSource.markAsRead(id);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to mark as read',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllRead() async {
    try {
      await _dataSource.markAllRead();
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to mark all as read',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
