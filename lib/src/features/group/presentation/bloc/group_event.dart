import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();
  @override
  List<Object?> get props => [];
}

class LoadGroups extends GroupEvent {}

class SelectGroup extends GroupEvent {
  final int groupId;
  const SelectGroup(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class CreateGroup extends GroupEvent {
  final String? name;
  const CreateGroup([this.name]);
  @override
  List<Object?> get props => [name];
}

class AddMember extends GroupEvent {
  final String username;
  final int? groupId;
  const AddMember(this.username, {this.groupId});
  @override
  List<Object?> get props => [username, groupId];
}

class RemoveMember extends GroupEvent {
  final int groupId;
  final int userId;

  const RemoveMember(this.groupId, this.userId);

  @override
  List<Object> get props => [groupId, userId];
}

class LoadGroupDetail extends GroupEvent {
  final int groupId;
  const LoadGroupDetail(this.groupId);
  @override
  List<Object?> get props => [groupId];
}
