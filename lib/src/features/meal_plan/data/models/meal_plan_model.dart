import '../../domain/entities/meal_plan.dart';

class MealPlanModel extends MealPlan {
  const MealPlanModel({
    required super.id,
    required super.mealType,
    required super.foodName,
    super.foodImageUrl,
    super.recipeId,
    super.date,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipe'];

    return MealPlanModel(
      id: json['id'],
      mealType:
          json['name'] ??
          '', // API returns 'name' as meal type (e.g. Breakfast)
      foodName: recipe != null ? (recipe['name'] ?? 'Món ăn') : 'Món ăn',
      foodImageUrl: null,
      recipeId: recipe != null ? recipe['id'] : null,
      date: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
    );
  }
}
