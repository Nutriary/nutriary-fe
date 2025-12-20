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
  const AddMember(this.username);
  @override
  List<Object?> get props => [username];
}

class LoadGroupDetail extends GroupEvent {
  final int groupId;
  const LoadGroupDetail(this.groupId);
  @override
  List<Object?> get props => [groupId];
}
