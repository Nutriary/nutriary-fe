import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/meal_plan.dart';

abstract class MealPlanRepository {
  Future<Either<Failure, List<MealPlan>>> getMealPlan(DateTime date);
  Future<Either<Failure, void>> addMealPlan(
    DateTime date,
    String mealType,
    String foodName,
    int? recipeId,
  );
  Future<Either<Failure, void>> deleteMealPlan(int id);
  Future<Either<Failure, List<String>>>
  getSuggestions(); // Or returns List<Food>? Repo says List<dynamic>
}
