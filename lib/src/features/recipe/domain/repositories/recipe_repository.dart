import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<Recipe>>> getAllRecipes();
  Future<Either<Failure, void>> createRecipe(
    String name,
    String content, {
    required List<Map<String, String>> ingredients,
    bool isPublic = true,
    int? groupId,
  });
  Future<Either<Failure, void>> updateRecipe(
    int id, {
    String? name,
    String? content,
    List<Map<String, String>>? ingredients,
  });
  Future<Either<Failure, void>> deleteRecipe(int id);
  Future<Either<Failure, List<Recipe>>> getRecipesByFood(int foodId);
}
