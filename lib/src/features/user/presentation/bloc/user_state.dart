import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

enum UserStatus { initial, loading, success, failure }

class UserState extends Equatable {
  final UserStatus status;
  final User? user;
  final String? errorMessage;
  final bool isLoadingAction;
  final bool isAccountDeleted;

  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoadingAction = false,
    this.isAccountDeleted = false,
  });

  UserState copyWith({
    UserStatus? status,
    User? user,
    String? errorMessage,
    bool? isLoadingAction,
    bool? isAccountDeleted,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
      isAccountDeleted: isAccountDeleted ?? this.isAccountDeleted,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    isLoadingAction,
    isAccountDeleted,
  ];
}
