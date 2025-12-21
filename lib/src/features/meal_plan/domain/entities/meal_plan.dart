import 'package:equatable/equatable.dart';

class MealPlan extends Equatable {
  final int id;
  final String mealType; // "Breakfast", etc. or mapped "Bữa Sáng"
  final String foodName;
  final String? foodImageUrl;
  final int? recipeId;
  final DateTime? date;

  const MealPlan({
    required this.id,
    required this.mealType,
    required this.foodName,
    this.foodImageUrl,
    this.recipeId,
    this.date,
  });

  @override
  List<Object?> get props => [
    id,
    mealType,
    foodName,
    foodImageUrl,
    recipeId,
    date,
  ];
}
