import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

class GetMealPlanParams extends Equatable {
  final DateTime date;
  final int? groupId;
  const GetMealPlanParams(this.date, {this.groupId});
  @override
  List<Object?> get props => [date, groupId];
}

@lazySingleton
class GetMealPlanUseCase extends UseCase<List<MealPlan>, GetMealPlanParams> {
  final MealPlanRepository repository;
  GetMealPlanUseCase(this.repository);
  @override
  Future<Either<Failure, List<MealPlan>>> call(GetMealPlanParams params) =>
      repository.getMealPlan(params.date, params.groupId);
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
        params.groupId,
      );
}

class AddMealPlanParams extends Equatable {
  final DateTime date;
  final String mealType;
  final String foodName;
  final int? recipeId;
  final int? groupId;
  const AddMealPlanParams(
    this.date,
    this.mealType,
    this.foodName, {
    this.recipeId,
    this.groupId,
  });
  @override
  List<Object?> get props => [date, mealType, foodName, recipeId, groupId];
}

@lazySingleton
class DeleteMealPlanUseCase extends UseCase<void, int> {
  final MealPlanRepository repository;
  DeleteMealPlanUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(int id) => repository.deleteMealPlan(id);
}

class GetSuggestionsParams extends Equatable {
  final int? groupId;
  const GetSuggestionsParams({this.groupId});
  @override
  List<Object?> get props => [groupId];
}

@lazySingleton
class GetMealSuggestionsUseCase
    extends UseCase<List<String>, GetSuggestionsParams> {
  final MealPlanRepository repository;
  GetMealSuggestionsUseCase(this.repository);
  @override
  Future<Either<Failure, List<String>>> call(GetSuggestionsParams params) =>
      repository.getSuggestions(params.groupId);
}
