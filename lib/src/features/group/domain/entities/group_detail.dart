import 'group.dart';
import 'package:equatable/equatable.dart';

class GroupDetail extends Group {
  final List<GroupMember> members;

  const GroupDetail({
    required super.id,
    required super.name,
    required this.members,
  });

  @override
  List<Object?> get props => [id, name, members];
}

class GroupMember extends Equatable {
  final String username;
  final String email;
  final String role;

  const GroupMember({
    required this.username,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [username, email, role];
}
