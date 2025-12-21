import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {}

class MarkAsRead extends NotificationEvent {
  final int id;
  const MarkAsRead(this.id);
  @override
  List<Object?> get props => [id];
}

class MarkAllRead extends NotificationEvent {}
