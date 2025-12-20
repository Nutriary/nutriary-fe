import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
}

@LazySingleton(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;
  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get('/notification');
    final data = (response.data as List?) ?? [];
    return data.map((e) => NotificationModel.fromJson(e)).toList();
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
}
