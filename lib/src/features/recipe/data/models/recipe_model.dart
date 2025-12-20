import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    super.htmlContent,
    super.foodName,
    super.imageUrl,
    super.foodId,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Recipe',
      htmlContent: json['htmlContent'],
      foodName: json['foodName'],
      imageUrl: json['food'] != null ? json['food']['foodImageUrl'] : null,
      foodId: json['food'] != null ? json['food']['id'] : null,
    );
  }
}
