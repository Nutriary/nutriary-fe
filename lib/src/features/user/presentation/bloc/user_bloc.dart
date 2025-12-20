import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/user_usecases.dart';
import 'user_event.dart';
import 'user_state.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateFcmTokenUseCase updateFcmTokenUseCase;

  UserBloc(this.getProfileUseCase, this.updateFcmTokenUseCase)
    : super(const UserState()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateFcmToken>(_onUpdateFcmToken);
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
}
