import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/shopping_usecases.dart';
import 'shopping_event.dart';
import 'shopping_state.dart';

@injectable
class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  final GetShoppingTasksUseCase getShoppingTasksUseCase;
  final CreateShoppingListUseCase createShoppingListUseCase;
  final AddShoppingTaskUseCase addShoppingTaskUseCase;
  final UpdateShoppingTaskUseCase updateShoppingTaskUseCase;
  final DeleteShoppingTaskUseCase deleteShoppingTaskUseCase;
  final ReorderShoppingTasksUseCase reorderShoppingTasksUseCase;

  ShoppingBloc(
    this.getShoppingTasksUseCase,
    this.createShoppingListUseCase,
    this.addShoppingTaskUseCase,
    this.updateShoppingTaskUseCase,
    this.deleteShoppingTaskUseCase,
    this.reorderShoppingTasksUseCase,
  ) : super(const ShoppingState()) {
    on<LoadShoppingTasks>(_onLoadTasks);
    on<CreateList>(_onCreateList);
    on<AddShoppingTask>(_onAddTask);
    on<UpdateShoppingTask>(_onUpdateTask);
    on<DeleteShoppingTask>(_onDeleteTask);
    on<ReorderShoppingTasks>(_onReorderTasks);
  }

  Future<void> _onLoadTasks(
    LoadShoppingTasks event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ShoppingStatus.loading,
        currentListId: event.listId,
      ),
    );
    final result = await getShoppingTasksUseCase(event.listId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ShoppingStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (tasks) =>
          emit(state.copyWith(status: ShoppingStatus.success, tasks: tasks)),
    );
  }

  Future<void> _onCreateList(
    CreateList event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await createShoppingListUseCase(
      CreateShoppingListParams(event.name, event.note, event.groupId),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) => emit(state.copyWith(isLoadingAction: false)),
    );
  }

  Future<void> _onAddTask(
    AddShoppingTask event,
    Emitter<ShoppingState> emit,
  ) async {
    // Optimistic Update? For now, standard loading.
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await addShoppingTaskUseCase(
      AddShoppingTaskParams(event.listId, event.foodName, event.quantity),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadShoppingTasks(event.listId));
      },
    );
  }

  Future<void> _onUpdateTask(
    UpdateShoppingTask event,
    Emitter<ShoppingState> emit,
  ) async {
    // Optimistic update logic could be handled here or in UI.
    // Let's do a simple state update first if it's a toggle bought

    // Not blocking UI with full loading for checkbox toggle
    // emit(state.copyWith(isLoadingAction: true));

    final result = await updateShoppingTaskUseCase(
      UpdateShoppingTaskParams(
        taskId: event.taskId,
        isBought: event.isBought,
        quantity: event.quantity,
      ),
    );

    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: failure.message)), // Show error
      (_) {
        // Optionally refresh, or rely on optimistic UI from widget
        add(LoadShoppingTasks(event.listId));
      },
    );
  }

  Future<void> _onDeleteTask(
    DeleteShoppingTask event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await deleteShoppingTaskUseCase(event.taskId);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadShoppingTasks(event.listId));
      },
    );
  }

  Future<void> _onReorderTasks(
    ReorderShoppingTasks event,
    Emitter<ShoppingState> emit,
  ) async {
    // Optimistic update of list order
    emit(state.copyWith(tasks: event.tasks));

    // Helper: update internal orderIndex of entities?
    // The usecase expects List<ShoppingTask> in the new order.
    // We don't necessarily need to update the orderIndex property on the objects before sending,
    // as the Repository logic maps index to orderIndex.

    final result = await reorderShoppingTasksUseCase(event.tasks);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => null, // Success, state already updated optimistically
    );
  }
}
