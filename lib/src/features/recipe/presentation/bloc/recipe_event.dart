import 'package:equatable/equatable.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllRecipes extends RecipeEvent {}

class LoadRecipesByFood extends RecipeEvent {
  final int foodId;
  const LoadRecipesByFood(this.foodId);
  @override
  List<Object?> get props => [foodId];
}

class CreateRecipe extends RecipeEvent {
  final String name;
  final String content;
  final List<Map<String, String>> ingredients;
  final bool isPublic;
  final int? groupId;
  const CreateRecipe({
    required this.name,
    required this.content,
    required this.ingredients,
    this.isPublic = true,
    this.groupId,
  });
  @override
  List<Object?> get props => [name, content, ingredients, isPublic, groupId];
}

class UpdateRecipe extends RecipeEvent {
  final int id;
  final String? name;
  final String? content;
  const UpdateRecipe({required this.id, this.name, this.content});
  @override
  List<Object?> get props => [id, name, content];
}

class DeleteRecipe extends RecipeEvent {
  final int id;
  const DeleteRecipe(this.id);
  @override
  List<Object?> get props => [id];
}
