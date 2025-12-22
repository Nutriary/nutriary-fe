import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {}

class ClearUserState extends UserEvent {}

class UpdateFcmToken extends UserEvent {
  final String token;
  const UpdateFcmToken(this.token);
  @override
  List<Object?> get props => [token];
}

class UpdateUserProfile extends UserEvent {
  final String? username;
  final String? imagePath;
  const UpdateUserProfile({this.username, this.imagePath});
  @override
  List<Object?> get props => [username, imagePath];
}

class ChangeUserPassword extends UserEvent {
  final String oldPassword;
  final String newPassword;
  const ChangeUserPassword({
    required this.oldPassword,
    required this.newPassword,
  });
  @override
  List<Object?> get props => [oldPassword, newPassword];
}

class DeleteUserAccount extends UserEvent {}
