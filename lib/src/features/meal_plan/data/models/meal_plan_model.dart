import '../../domain/entities/meal_plan.dart';

class MealPlanModel extends MealPlan {
  const MealPlanModel({
    required super.id,
    required super.mealType,
    required super.foodName,
    super.recipeId,
    super.date,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'],
      mealType:
          json['name'] ??
          '', // API returns 'name' as meal type (e.g. Breakfast)
      foodName: json['foodName'] ?? '',
      recipeId: json['recipeId'],
      date: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
    );
  }
}
