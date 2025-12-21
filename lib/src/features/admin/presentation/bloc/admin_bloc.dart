import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_system_stats_usecase.dart';
import '../../domain/usecases/get_admin_users_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import 'admin_event.dart';
import 'admin_state.dart';

@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetSystemStatsUseCase getSystemStatsUseCase;
  final GetAdminUsersUseCase getAdminUsersUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;

  AdminBloc(
    this.getSystemStatsUseCase,
    this.getAdminUsersUseCase,
    this.updateUserRoleUseCase,
  ) : super(const AdminState()) {
    on<LoadAdminStats>(_onLoadStats);
    on<LoadAdminUsers>(_onLoadUsers);
    on<UpdateUserRole>(_onUpdateUserRole);
  }

  Future<void> _onLoadStats(
    LoadAdminStats event,
    Emitter<AdminState> emit,
  ) async {
    // Only loading if no data? Or silent refresh? Standard loading for now.
    // If we want detailed loading, maybe separate status?
    // User Management modifies status too. Careful.
    // I'll stick to simple loading.
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await getSystemStatsUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stats) =>
          emit(state.copyWith(status: AdminStatus.success, stats: stats)),
    );
  }

  Future<void> _onLoadUsers(
    LoadAdminUsers event,
    Emitter<AdminState> emit,
  ) async {
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await getAdminUsersUseCase(
      GetAdminUsersParams(page: event.page, size: event.size),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (users) =>
          emit(state.copyWith(status: AdminStatus.success, users: users)),
    );
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRole event,
    Emitter<AdminState> emit,
  ) async {
    // Optimistic Update? Or Loading?
    // Simple: Loading -> Success -> Refresh List
    emit(state.copyWith(status: AdminStatus.loading));
    final result = await updateUserRoleUseCase(
      UpdateUserRoleParams(userId: event.userId, role: event.role),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        // Refresh users list
        add(const LoadAdminUsers());
      },
    );
  }
}
