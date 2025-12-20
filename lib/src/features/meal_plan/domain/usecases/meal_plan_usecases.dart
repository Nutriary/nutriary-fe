import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

@lazySingleton
class GetMealPlanUseCase extends UseCase<List<MealPlan>, DateTime> {
  final MealPlanRepository repository;
  GetMealPlanUseCase(this.repository);
  @override
  Future<Either<Failure, List<MealPlan>>> call(DateTime date) =>
      repository.getMealPlan(date);
}

@lazySingleton
class AddMealPlanUseCase extends UseCase<void, AddMealPlanParams> {
  final MealPlanRepository repository;
  AddMealPlanUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(AddMealPlanParams params) =>
      repository.addMealPlan(
        params.date,
        params.mealType,
        params.foodName,
        params.recipeId,
      );
}

class AddMealPlanParams extends Equatable {
  final DateTime date;
  final String mealType;
  final String foodName;
  final int? recipeId;
  const AddMealPlanParams(
    this.date,
    this.mealType,
    this.foodName, [
    this.recipeId,
  ]);
  @override
  List<Object?> get props => [date, mealType, foodName, recipeId];
}

@lazySingleton
class DeleteMealPlanUseCase extends UseCase<void, int> {
  final MealPlanRepository repository;
  DeleteMealPlanUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(int id) => repository.deleteMealPlan(id);
}

@lazySingleton
class GetMealSuggestionsUseCase extends UseCase<List<String>, NoParams> {
  final MealPlanRepository repository;
  GetMealSuggestionsUseCase(this.repository);
  @override
  Future<Either<Failure, List<String>>> call(NoParams params) =>
      repository.getSuggestions();
}
