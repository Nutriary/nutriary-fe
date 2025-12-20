import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe.dart';

enum RecipeStatus { initial, loading, success, failure }

class RecipeState extends Equatable {
  final RecipeStatus status;
  final List<Recipe> recipes;
  final List<Recipe> filteredRecipes;
  final String? errorMessage;
  final bool isLoadingAction;

  const RecipeState({
    this.status = RecipeStatus.initial,
    this.recipes = const [],
    this.filteredRecipes = const [],
    this.errorMessage,
    this.isLoadingAction = false,
  });

  RecipeState copyWith({
    RecipeStatus? status,
    List<Recipe>? recipes,
    List<Recipe>? filteredRecipes,
    String? errorMessage,
    bool? isLoadingAction,
  }) {
    return RecipeState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      filteredRecipes: filteredRecipes ?? this.filteredRecipes,
      errorMessage: errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recipes,
    filteredRecipes,
    errorMessage,
    isLoadingAction,
  ];
}
