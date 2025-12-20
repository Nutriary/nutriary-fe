import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

@lazySingleton
class GetAllRecipesUseCase extends UseCase<List<Recipe>, NoParams> {
  final RecipeRepository repository;
  GetAllRecipesUseCase(this.repository);
  @override
  Future<Either<Failure, List<Recipe>>> call(NoParams params) =>
      repository.getAllRecipes();
}

@lazySingleton
class CreateRecipeUseCase extends UseCase<void, CreateRecipeParams> {
  final RecipeRepository repository;
  CreateRecipeUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(CreateRecipeParams params) =>
      repository.createRecipe(params.name, params.foodName, params.content);
}

class CreateRecipeParams extends Equatable {
  final String name;
  final String foodName;
  final String content;
  const CreateRecipeParams(this.name, this.foodName, this.content);
  @override
  List<Object?> get props => [name, foodName, content];
}

@lazySingleton
class UpdateRecipeUseCase extends UseCase<void, UpdateRecipeParams> {
  final RecipeRepository repository;
  UpdateRecipeUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(UpdateRecipeParams params) => repository
      .updateRecipe(params.id, name: params.name, content: params.content);
}

class UpdateRecipeParams extends Equatable {
  final int id;
  final String? name;
  final String? content;
  const UpdateRecipeParams({required this.id, this.name, this.content});
  @override
  List<Object?> get props => [id, name, content];
}

@lazySingleton
class DeleteRecipeUseCase extends UseCase<void, int> {
  final RecipeRepository repository;
  DeleteRecipeUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(int id) => repository.deleteRecipe(id);
}

@lazySingleton
class GetRecipesByFoodUseCase extends UseCase<List<Recipe>, int> {
  final RecipeRepository repository;
  GetRecipesByFoodUseCase(this.repository);
  @override
  Future<Either<Failure, List<Recipe>>> call(int foodId) =>
      repository.getRecipesByFood(foodId);
}
