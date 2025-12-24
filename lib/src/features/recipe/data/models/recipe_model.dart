import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    super.htmlContent,
    super.description,
    super.foodName,
    super.imageUrl,
    super.foodId,
    super.isPublic,
    super.groupId,
    super.groupName,
    super.createdByName,
    super.ingredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final food = json['food'];
    final group = json['group'];
    final createdBy = json['createdBy'];

    // Parse ingredients array - handle null safely
    List<RecipeIngredient> ingredients = [];
    final ingredientsJson = json['ingredients'];
    print('DEBUG Recipe ${json['id']} ingredients: $ingredientsJson');
    if (ingredientsJson != null && ingredientsJson is List) {
      ingredients = ingredientsJson.map<RecipeIngredient>((ing) {
        final ingFood = ing['food'];
        return RecipeIngredient(
          id: ing['id'],
          name: ing['name'] ?? '',
          quantity: (ing['quantity'] is num)
              ? (ing['quantity'] as num).toDouble()
              : double.tryParse(ing['quantity']?.toString() ?? '0') ?? 0,
          unit: ing['unit'] ?? '',
          foodId: ingFood != null ? ingFood['id'] : null,
        );
      }).toList();
    }

    return RecipeModel(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Recipe',
      htmlContent: json['html_content'] ?? json['htmlContent'],
      description: json['description'],
      foodName: food != null ? food['name'] : json['foodName'],
      imageUrl: food != null ? food['foodImageUrl'] : null,
      foodId: food != null ? food['id'] : null,
      isPublic: json['isPublic'] ?? true,
      groupId: group != null ? group['id'] : null,
      groupName: group != null ? group['name'] : null,
      createdByName: createdBy != null ? createdBy['name'] : null,
      ingredients: ingredients,
    );
  }
}
