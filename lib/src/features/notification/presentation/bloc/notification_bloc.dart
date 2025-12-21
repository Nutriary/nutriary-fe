import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/notification_usecases.dart';
import 'notification_event.dart';
import 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllReadUseCase markAllReadUseCase;

  NotificationBloc(
    this.getNotificationsUseCase,
    this.markAsReadUseCase,
    this.markAllReadUseCase,
  ) : super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllRead>(_onMarkAllRead);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    final result = await getNotificationsUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (notifications) => emit(
        state.copyWith(
          status: NotificationStatus.success,
          notifications: notifications,
        ),
      ),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAsReadUseCase(event.id);
    result.fold(
      (failure) => null, // Silent failure or show snackbar? Silent for now
      (_) {
        final updated = state.notifications.map((n) {
          if (n.id == event.id) {
            return NotificationEntity(
              id: n.id,
              title: n.title,
              body: n.body,
              isRead: true,
              createdAt: n.createdAt,
              data: n.data,
            );
          }
          return n;
        }).toList();
        emit(state.copyWith(notifications: updated));
      },
    );
  }

  Future<void> _onMarkAllRead(
    MarkAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await markAllReadUseCase(NoParams());
    result.fold((failure) => null, (_) {
      final updated = state.notifications.map((n) {
        return NotificationEntity(
          id: n.id,
          title: n.title,
          body: n.body,
          isRead: true,
          createdAt: n.createdAt,
          data: n.data,
        );
      }).toList();
      emit(state.copyWith(notifications: updated));
    });
  }
}
