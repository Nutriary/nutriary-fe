import 'package:equatable/equatable.dart';
import 'package:nutriary_fe/src/features/user/domain/entities/user.dart';
import '../../domain/entities/system_stats.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  final AdminStatus status;
  final SystemStats? stats;
  final List<User> users;
  final String? errorMessage;

  const AdminState({
    this.status = AdminStatus.initial,
    this.stats,
    this.users = const [],
    this.errorMessage,
  });

  AdminState copyWith({
    AdminStatus? status,
    SystemStats? stats,
    List<User>? users,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, users, errorMessage];
}
