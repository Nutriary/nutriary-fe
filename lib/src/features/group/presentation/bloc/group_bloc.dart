import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_groups_usecase.dart';
import '../../domain/usecases/get_group_detail_usecase.dart';
import '../../domain/usecases/add_member_usecase.dart';
import '../../domain/usecases/create_group_usecase.dart';
import 'group_event.dart';
import 'group_state.dart';

import '../../domain/usecases/remove_member_usecase.dart';

@lazySingleton
class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetGroupsUseCase getGroupsUseCase;
  final GetGroupDetailUseCase getGroupDetailUseCase;
  final AddMemberUseCase addMemberUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final RemoveMemberUseCase removeMemberUseCase;

  GroupBloc(
    this.getGroupsUseCase,
    this.getGroupDetailUseCase,
    this.addMemberUseCase,
    this.createGroupUseCase,
    this.removeMemberUseCase,
  ) : super(const GroupState()) {
    on<LoadGroups>(_onLoadGroups);
    on<SelectGroup>(_onSelectGroup);
    on<AddMember>(_onAddMember);
    on<RemoveMember>(_onRemoveMember);
    on<LoadGroupDetail>(_onLoadGroupDetail);
    on<CreateGroup>(_onCreateGroup);
  }

  Future<void> _onLoadGroups(LoadGroups event, Emitter<GroupState> emit) async {
    emit(state.copyWith(status: GroupStatus.loading));
    final result = await getGroupsUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GroupStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (groups) {
        int? selectedId = state.selectedGroupId;
        // Default to first group if none selected and groups exist
        if (selectedId == null && groups.isNotEmpty) {
          selectedId = groups.first.id;
        } else if (selectedId != null &&
            !groups.any((g) => g.id == selectedId)) {
          // If selected group no longer exists, default to first or null
          selectedId = groups.isNotEmpty ? groups.first.id : null;
        }

        emit(
          state.copyWith(
            status: GroupStatus.success,
            groups: groups,
            selectedGroupId: selectedId,
          ),
        );

        if (selectedId != null) {
          add(LoadGroupDetail(selectedId));
        }
      },
    );
  }

  void _onSelectGroup(SelectGroup event, Emitter<GroupState> emit) {
    emit(state.copyWith(selectedGroupId: event.groupId));
    add(LoadGroupDetail(event.groupId));
  }

  Future<void> _onLoadGroupDetail(
    LoadGroupDetail event,
    Emitter<GroupState> emit,
  ) async {
    emit(state.copyWith(isDetailLoading: true));
    final result = await getGroupDetailUseCase(event.groupId);
    result.fold(
      (failure) => emit(
        state.copyWith(isDetailLoading: false, errorMessage: failure.message),
      ),
      (detail) =>
          emit(state.copyWith(isDetailLoading: false, groupDetail: detail)),
    );
  }

  Future<void> _onAddMember(AddMember event, Emitter<GroupState> emit) async {
    final result = await addMemberUseCase(event.username);
    result.fold(
      (failure) => emit(
        state.copyWith(errorMessage: failure.message),
      ), // Show snackbar in UI listener
      (_) {
        if (state.selectedGroupId != null) {
          add(LoadGroupDetail(state.selectedGroupId!));
        }
      },
    );
  }

  Future<void> _onRemoveMember(
    RemoveMember event,
    Emitter<GroupState> emit,
  ) async {
    final result = await removeMemberUseCase(
      RemoveMemberParams(groupId: event.groupId, userId: event.userId),
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        if (state.selectedGroupId != null) {
          add(LoadGroupDetail(state.selectedGroupId!));
        }
      },
    );
  }

  Future<void> _onCreateGroup(
    CreateGroup event,
    Emitter<GroupState> emit,
  ) async {
    if (event.name == null || event.name!.isEmpty) return;
    emit(state.copyWith(status: GroupStatus.loading));
    final result = await createGroupUseCase(event.name!);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: GroupStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        add(LoadGroups()); // Refresh groups after creation
      },
    );
  }
}
