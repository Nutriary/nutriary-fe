import 'package:equatable/equatable.dart';

abstract class MealPlanEvent extends Equatable {
  const MealPlanEvent();
  @override
  List<Object?> get props => [];
}

class LoadMealPlan extends MealPlanEvent {
  final DateTime date;
  const LoadMealPlan(this.date);
  @override
  List<Object?> get props => [date];
}

class AddMealPlan extends MealPlanEvent {
  final DateTime date;
  final String mealType;
  final String foodName;
  final int? recipeId;
  const AddMealPlan({
    required this.date,
    required this.mealType,
    required this.foodName,
    this.recipeId,
  });
  @override
  List<Object?> get props => [date, mealType, foodName, recipeId];
}

class DeleteMealPlan extends MealPlanEvent {
  final int id;
  final DateTime currentDate; // To reload list
  const DeleteMealPlan(this.id, this.currentDate);
  @override
  List<Object?> get props => [id, currentDate];
}

class LoadSuggestions extends MealPlanEvent {}
