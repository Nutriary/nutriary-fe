import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

@lazySingleton
class GetNotificationsUseCase
    extends UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);
  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams params) =>
      repository.getNotifications();
}

@lazySingleton
class MarkAsReadUseCase extends UseCase<void, int> {
  final NotificationRepository repository;
  MarkAsReadUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(int params) =>
      repository.markAsRead(params);
}

@lazySingleton
class MarkAllReadUseCase extends UseCase<void, NoParams> {
  final NotificationRepository repository;
  MarkAllReadUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.markAllRead();
}
