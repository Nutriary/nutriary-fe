import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/recipe_usecases.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

@injectable
class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GetAllRecipesUseCase getAllRecipesUseCase;
  final CreateRecipeUseCase createRecipeUseCase;
  final UpdateRecipeUseCase updateRecipeUseCase;
  final DeleteRecipeUseCase deleteRecipeUseCase;
  final GetRecipesByFoodUseCase getRecipesByFoodUseCase;

  RecipeBloc(
    this.getAllRecipesUseCase,
    this.createRecipeUseCase,
    this.updateRecipeUseCase,
    this.deleteRecipeUseCase,
    this.getRecipesByFoodUseCase,
  ) : super(const RecipeState()) {
    on<LoadAllRecipes>(_onLoadAllRecipes);
    on<CreateRecipe>(_onCreateRecipe);
    on<UpdateRecipe>(_onUpdateRecipe);
    on<DeleteRecipe>(_onDeleteRecipe);
    on<LoadRecipesByFood>(_onLoadRecipesByFood);
  }

  Future<void> _onLoadAllRecipes(
    LoadAllRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    final result = await getAllRecipesUseCase(NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RecipeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (recipes) => emit(
        state.copyWith(
          status: RecipeStatus.success,
          recipes: recipes,
          filteredRecipes: recipes, // Initially all
        ),
      ),
    );
  }

  Future<void> _onLoadRecipesByFood(
    LoadRecipesByFood event,
    Emitter<RecipeState> emit,
  ) async {
    // Specialized loading? Or general.
    // Usually we replace the list with filtered list or handle separate list.
    // Let's assume this is for a specific view or filtering.
    // For now, let's treat it as "filter by food" logic or simply fetch and show.
    // Given the previous screen, likely we want to show recipes associated with food.
    emit(state.copyWith(status: RecipeStatus.loading));
    final result = await getRecipesByFoodUseCase(event.foodId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: RecipeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (recipes) => emit(
        state.copyWith(
          status: RecipeStatus.success,
          recipes: recipes,
          filteredRecipes: recipes,
        ),
      ),
    );
  }

  Future<void> _onCreateRecipe(
    CreateRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await createRecipeUseCase(
      CreateRecipeParams(
        event.name,
        event.content,
        ingredients: event.ingredients,
        isPublic: event.isPublic,
        groupId: event.groupId,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadAllRecipes()); // Refresh
      },
    );
  }

  Future<void> _onUpdateRecipe(
    UpdateRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await updateRecipeUseCase(
      UpdateRecipeParams(
        id: event.id,
        name: event.name,
        content: event.content,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadAllRecipes()); // Refresh
      },
    );
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    emit(state.copyWith(isLoadingAction: true, errorMessage: null));
    final result = await deleteRecipeUseCase(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingAction: false, errorMessage: failure.message),
      ),
      (_) {
        emit(state.copyWith(isLoadingAction: false));
        add(LoadAllRecipes()); // Refresh
      },
    );
  }
}
