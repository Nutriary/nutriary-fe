import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_foods_usecase.dart';
import '../../domain/usecases/create_food_usecase.dart';
import '../../domain/usecases/update_food_usecase.dart';
import '../../domain/usecases/delete_food_usecase.dart';
import 'food_event.dart';
import 'food_state.dart';

@injectable
class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final GetFoodsUseCase getFoodsUseCase;
  final CreateFoodUseCase createFoodUseCase;
  final UpdateFoodUseCase updateFoodUseCase;
  final DeleteFoodUseCase deleteFoodUseCase;

  FoodBloc(
    this.getFoodsUseCase,
    this.createFoodUseCase,
    this.updateFoodUseCase,
    this.deleteFoodUseCase,
  ) : super(const FoodState()) {
    on<LoadFoods>(_onLoadFoods);
    on<CreateFood>(_onCreateFood);
    on<UpdateFood>(_onUpdateFood);
    on<DeleteFood>(_onDeleteFood);
  }

  Future<void> _onLoadFoods(LoadFoods event, Emitter<FoodState> emit) async {
    emit(state.copyWith(status: FoodStatus.loading));
    final result = await getFoodsUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: FoodStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (foods) => emit(state.copyWith(status: FoodStatus.success, foods: foods)),
    );
  }

  Future<void> _onCreateFood(CreateFood event, Emitter<FoodState> emit) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await createFoodUseCase(
      CreateFoodParams(
        name: event.name,
        category: event.category,
        unit: event.unit,
        image: event.image,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadFoods());
      },
    );
  }

  Future<void> _onUpdateFood(UpdateFood event, Emitter<FoodState> emit) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await updateFoodUseCase(
      UpdateFoodParams(
        name: event.name,
        newCategory: event.newCategory,
        newUnit: event.newUnit,
        image: event.image,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadFoods());
      },
    );
  }

  Future<void> _onDeleteFood(DeleteFood event, Emitter<FoodState> emit) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await deleteFoodUseCase(event.name);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        // Optimistic update or reload
        final updatedFoods = state.foods
            .where((f) => f.name != event.name)
            .toList();
        emit(state.copyWith(isLoadingAction: false, foods: updatedFoods));
        // add(LoadFoods()); // Optional, if we want to sync with server
      },
    );
  }
}
