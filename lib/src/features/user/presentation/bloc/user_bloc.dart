import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../domain/usecases/update_user_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateFcmTokenUseCase updateFcmTokenUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  UserBloc(
    this.getProfileUseCase,
    this.updateFcmTokenUseCase,
    this.updateUserUseCase,
    this.changePasswordUseCase,
    this.deleteAccountUseCase,
  ) : super(const UserState()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateFcmToken>(_onUpdateFcmToken);
    on<ClearUserState>(_onClearUserState);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ChangeUserPassword>(_onChangeUserPassword);
    on<DeleteUserAccount>(_onDeleteUserAccount);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));
    final result = await getProfileUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(status: UserStatus.success, user: user)),
    );
  }

  Future<void> _onUpdateFcmToken(
    UpdateFcmToken event,
    Emitter<UserState> emit,
  ) async {
    final result = await updateFcmTokenUseCase(event.token);
    result.fold(
      (failure) => null, // Just ignore failure for FCM token update
      (_) => null,
    );
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await updateUserUseCase(
      UpdateUserParams(username: event.username, imagePath: event.imagePath),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (user) => emit(
        state.copyWith(
          isLoadingAction: false,
          user: user,
          // Optional: trigger success message via a one-off field if needed, currently just updating user
        ),
      ),
    );
  }

  Future<void> _onChangeUserPassword(
    ChangeUserPassword event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await changePasswordUseCase(
      ChangePasswordParams(event.oldPassword, event.newPassword),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) => emit(state.copyWith(isLoadingAction: false)),
    );
  }

  Future<void> _onDeleteUserAccount(
    DeleteUserAccount event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await deleteAccountUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) =>
          emit(state.copyWith(isLoadingAction: false, isAccountDeleted: true)),
    );
  }

  void _onClearUserState(ClearUserState event, Emitter<UserState> emit) {
    emit(const UserState());
  }
}
