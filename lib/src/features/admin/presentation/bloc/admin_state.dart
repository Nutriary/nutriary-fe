import 'package:equatable/equatable.dart';
import 'package:nutriary_fe/src/features/user/domain/entities/user.dart';
import '../../domain/entities/system_stats.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  final AdminStatus status;
  final SystemStats? stats;
  final List<User> users;
  final String? errorMessage;
  final bool isLoadingAction;

  const AdminState({
    this.status = AdminStatus.initial,
    this.stats,
    this.users = const [],
    this.errorMessage,
    this.isLoadingAction = false,
  });

  AdminState copyWith({
    AdminStatus? status,
    SystemStats? stats,
    List<User>? users,
    String? errorMessage,
    bool? isLoadingAction,
  }) {
    return AdminState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      users: users ?? this.users,
      errorMessage: errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stats,
    users,
    errorMessage,
    isLoadingAction,
  ];
}
