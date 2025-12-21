import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutriary_fe/src/core/usecase/usecase.dart';
import '../../domain/usecases/get_fridge_items_usecase.dart';
import '../../domain/usecases/manage_fridge_items_usecase.dart';
import '../../../category/domain/usecases/get_categories_usecase.dart';
import 'fridge_event.dart';
import 'fridge_state.dart';

@injectable
class FridgeBloc extends Bloc<FridgeEvent, FridgeState> {
  final GetFridgeItemsUseCase getFridgeItemsUseCase;
  final AddFridgeItemUseCase addFridgeItemUseCase;
  final UpdateFridgeItemUseCase updateFridgeItemUseCase;
  final RemoveFridgeItemUseCase removeFridgeItemUseCase;
  final ConsumeFridgeItemUseCase consumeFridgeItemUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  FridgeBloc(
    this.getFridgeItemsUseCase,
    this.addFridgeItemUseCase,
    this.updateFridgeItemUseCase,
    this.removeFridgeItemUseCase,
    this.consumeFridgeItemUseCase,
    this.getCategoriesUseCase,
  ) : super(const FridgeState()) {
    on<LoadFridgeItems>(_onLoadFridgeItems);
    on<LoadCategories>(_onLoadCategories);
    on<ChangeFilter>(_onChangeFilter);
    on<AddItem>(_onAddItem);
    on<UpdateItem>(_onUpdateItem);
    on<RemoveItem>(_onRemoveItem);
    on<ConsumeItem>(_onConsumeItem);
  }

  Future<void> _onLoadFridgeItems(
    LoadFridgeItems event,
    Emitter<FridgeState> emit,
  ) async {
    emit(state.copyWith(status: FridgeStatus.loading));
    final result = await getFridgeItemsUseCase(event.groupId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FridgeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) =>
          emit(state.copyWith(status: FridgeStatus.success, items: items)),
    );
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<FridgeState> emit,
  ) async {
    final result = await getCategoriesUseCase(NoParams());
    result.fold(
      (failure) => null,
      (categories) => emit(state.copyWith(categories: categories)),
    );
  }

  void _onChangeFilter(ChangeFilter event, Emitter<FridgeState> emit) {
    if (event.filter == 'Expiring') {
      emit(state.copyWith(filter: FridgeFilter.expiring));
    } else {
      emit(state.copyWith(filter: FridgeFilter.all));
    }
  }

  Future<void> _onAddItem(AddItem event, Emitter<FridgeState> emit) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await addFridgeItemUseCase(
      AddFridgeItemParams(
        foodName: event.foodName,
        quantity: event.quantity,
        useWithin: event.useWithin,
        categoryName: event.categoryName,
        groupId: event.groupId,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadFridgeItems(event.groupId));
      },
    );
  }

  Future<void> _onUpdateItem(
    UpdateItem event,
    Emitter<FridgeState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await updateFridgeItemUseCase(
      UpdateFridgeItemParams(
        foodName: event.foodName,
        quantity: event.quantity,
        useWithin: event.useWithin,
        groupId: event.groupId,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadFridgeItems(event.groupId));
      },
    );
  }

  Future<void> _onRemoveItem(
    RemoveItem event,
    Emitter<FridgeState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await removeFridgeItemUseCase(
      RemoveFridgeItemParams(event.foodName, event.groupId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadFridgeItems(event.groupId));
      },
    );
  }

  Future<void> _onConsumeItem(
    ConsumeItem event,
    Emitter<FridgeState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await consumeFridgeItemUseCase(
      ConsumeFridgeItemParams(
        foodName: event.foodName,
        quantity: event.quantity,
        groupId: event.groupId,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadFridgeItems(event.groupId));
      },
    );
  }
}
