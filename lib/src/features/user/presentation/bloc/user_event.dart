import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {}

class UpdateFcmToken extends UserEvent {
  final String token;
  const UpdateFcmToken(this.token);
  @override
  List<Object?> get props => [token];
}
