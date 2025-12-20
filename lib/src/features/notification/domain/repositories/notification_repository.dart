import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
}
