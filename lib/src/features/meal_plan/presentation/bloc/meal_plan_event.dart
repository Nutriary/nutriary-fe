import 'package:equatable/equatable.dart';

abstract class MealPlanEvent extends Equatable {
  const MealPlanEvent();
  @override
  List<Object?> get props => [];
}

class LoadMealPlan extends MealPlanEvent {
  final DateTime date;
  final int? groupId;
  const LoadMealPlan(this.date, {this.groupId});
  @override
  List<Object?> get props => [date, groupId];
}

class AddMealPlan extends MealPlanEvent {
  final DateTime date;
  final String mealType;
  final String foodName;
  final int? recipeId;
  final int? groupId;
  const AddMealPlan({
    required this.date,
    required this.mealType,
    required this.foodName,
    this.recipeId,
    this.groupId,
  });
  @override
  List<Object?> get props => [date, mealType, foodName, recipeId, groupId];
}

class DeleteMealPlan extends MealPlanEvent {
  final int id;
  final DateTime currentDate; // To reload list
  final int? groupId;
  const DeleteMealPlan(this.id, this.currentDate, {this.groupId});
  @override
  List<Object?> get props => [id, currentDate, groupId];
}

class LoadSuggestions extends MealPlanEvent {
  final int? groupId;
  const LoadSuggestions({this.groupId});
  @override
  List<Object?> get props => [groupId];
}
