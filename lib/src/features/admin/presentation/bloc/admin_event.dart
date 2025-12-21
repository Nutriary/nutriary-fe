import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminStats extends AdminEvent {}

class LoadAdminUsers extends AdminEvent {
  final int page;
  final int size;
  const LoadAdminUsers({this.page = 1, this.size = 20});
  @override
  List<Object> get props => [page, size];
}

class UpdateUserRole extends AdminEvent {
  final int userId;
  final String role;
  const UpdateUserRole({required this.userId, required this.role});
  @override
  List<Object> get props => [userId, role];
}
