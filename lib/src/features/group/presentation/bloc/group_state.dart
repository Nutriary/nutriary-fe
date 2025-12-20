import 'package:equatable/equatable.dart';
import '../../domain/entities/group.dart';

import '../../domain/entities/group_detail.dart';

enum GroupStatus { initial, loading, success, failure }

class GroupState extends Equatable {
  final GroupStatus status;
  final List<Group> groups;
  final int? selectedGroupId;
  final GroupDetail? groupDetail;
  final String? errorMessage;
  final bool isDetailLoading;

  const GroupState({
    this.status = GroupStatus.initial,
    this.groups = const [],
    this.selectedGroupId,
    this.groupDetail,
    this.errorMessage,
    this.isDetailLoading = false,
  });

  Group? get selectedGroup {
    if (selectedGroupId == null) return null;
    return groups.lookup(selectedGroupId!);
  }

  GroupState copyWith({
    GroupStatus? status,
    List<Group>? groups,
    int? selectedGroupId,
    GroupDetail? groupDetail,
    String? errorMessage,
    bool? isDetailLoading,
  }) {
    return GroupState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      selectedGroupId: selectedGroupId ?? this.selectedGroupId,
      groupDetail: groupDetail ?? this.groupDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
    );
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    selectedGroupId,
    groupDetail,
    errorMessage,
    isDetailLoading,
  ];
}

extension GroupListExtension on List<Group> {
  Group? lookup(int id) {
    try {
      return firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }
}
