import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/meal_plan_usecases.dart';
import 'meal_plan_event.dart';
import 'meal_plan_state.dart';

@injectable
class MealPlanBloc extends Bloc<MealPlanEvent, MealPlanState> {
  final GetMealPlanUseCase getMealPlanUseCase;
  final AddMealPlanUseCase addMealPlanUseCase;
  final DeleteMealPlanUseCase deleteMealPlanUseCase;
  final GetMealSuggestionsUseCase getMealSuggestionsUseCase;

  MealPlanBloc(
    this.getMealPlanUseCase,
    this.addMealPlanUseCase,
    this.deleteMealPlanUseCase,
    this.getMealSuggestionsUseCase,
  ) : super(const MealPlanState()) {
    on<LoadMealPlan>(_onLoadMealPlan);
    on<AddMealPlan>(_onAddMealPlan);
    on<DeleteMealPlan>(_onDeleteMealPlan);
    on<LoadSuggestions>(_onLoadSuggestions);
  }

  Future<void> _onLoadMealPlan(
    LoadMealPlan event,
    Emitter<MealPlanState> emit,
  ) async {
    emit(
      state.copyWith(status: MealPlanStatus.loading, selectedDate: event.date),
    );
    final result = await getMealPlanUseCase(event.date);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MealPlanStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (plans) => emit(
        state.copyWith(status: MealPlanStatus.success, mealPlans: plans),
      ),
    );
  }

  Future<void> _onAddMealPlan(
    AddMealPlan event,
    Emitter<MealPlanState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await addMealPlanUseCase(
      AddMealPlanParams(
        event.date,
        event.mealType,
        event.foodName,
        event.recipeId,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadMealPlan(event.date)); // Refresh list
      },
    );
  }

  Future<void> _onDeleteMealPlan(
    DeleteMealPlan event,
    Emitter<MealPlanState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await deleteMealPlanUseCase(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadMealPlan(event.currentDate)); // Refresh list
      },
    );
  }

  Future<void> _onLoadSuggestions(
    LoadSuggestions event,
    Emitter<MealPlanState> emit,
  ) async {
    final result = await getMealSuggestionsUseCase(NoParams());
    result.fold(
      (failure) => null, // Ignore sugg fail
      (suggestions) => emit(state.copyWith(suggestions: suggestions)),
    );
  }
}
