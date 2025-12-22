import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_units_usecase.dart';
import '../../domain/usecases/create_unit_usecase.dart';
import '../../domain/usecases/update_unit_usecase.dart';
import '../../domain/usecases/delete_unit_usecase.dart';
import 'unit_event.dart';
import 'unit_state.dart';

@injectable
class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final GetUnitsUseCase getUnitsUseCase;
  final CreateUnitUseCase createUnitUseCase;
  final UpdateUnitUseCase updateUnitUseCase;
  final DeleteUnitUseCase deleteUnitUseCase;

  UnitBloc(
    this.getUnitsUseCase,
    this.createUnitUseCase,
    this.updateUnitUseCase,
    this.deleteUnitUseCase,
  ) : super(const UnitState()) {
    on<LoadUnits>(_onLoad);
    on<CreateUnit>(_onCreate);
    on<UpdateUnit>(_onUpdate);
    on<DeleteUnit>(_onDelete);
  }

  Future<void> _onLoad(LoadUnits event, Emitter<UnitState> emit) async {
    emit(state.copyWith(status: UnitStatus.loading));
    final result = await getUnitsUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: UnitStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (units) => emit(state.copyWith(status: UnitStatus.success, units: units)),
    );
  }

  Future<void> _onCreate(CreateUnit event, Emitter<UnitState> emit) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await createUnitUseCase(event.name);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadUnits());
      },
    );
  }

  Future<void> _onUpdate(UpdateUnit event, Emitter<UnitState> emit) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await updateUnitUseCase(
      UpdateUnitParams(event.oldName, event.newName),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadUnits());
      },
    );
  }

  Future<void> _onDelete(DeleteUnit event, Emitter<UnitState> emit) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await deleteUnitUseCase(event.name);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadUnits());
      },
    );
  }
}
