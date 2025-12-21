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
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final food = json['food'];
    final group = json['group'];
    final createdBy = json['createdBy'];

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
    );
  }
}
