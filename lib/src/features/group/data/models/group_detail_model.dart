import '../../domain/entities/group_detail.dart';

class GroupDetailModel extends GroupDetail {
  const GroupDetailModel({
    required super.id,
    required super.name,
    required super.members,
  });

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    return GroupDetailModel(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Group',
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => GroupMemberModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.userId,
    required super.username,
    required super.email,
    required super.role,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return GroupMemberModel(
      userId: user['id'] ?? 0,
      username: user['username'] ?? 'Unknown',
      email: user['email'] ?? '',
      role: json['role'] ?? 'member',
    );
  }
}
