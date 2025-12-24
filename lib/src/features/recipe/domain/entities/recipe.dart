import 'package:equatable/equatable.dart';

class RecipeIngredient extends Equatable {
  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final int? foodId;

  const RecipeIngredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.foodId,
  });

  @override
  List<Object?> get props => [id, name, quantity, unit, foodId];
}

class Recipe extends Equatable {
  final int id;
  final String name;
  final String? htmlContent;
  final String? description;
  final String? foodName;
  final String? imageUrl;
  final int? foodId;
  final bool isPublic;
  final int? groupId;
  final String? groupName;
  final String? createdByName;
  final List<RecipeIngredient> ingredients;

  const Recipe({
    required this.id,
    required this.name,
    this.htmlContent,
    this.description,
    this.foodName,
    this.imageUrl,
    this.foodId,
    this.isPublic = true,
    this.groupId,
    this.groupName,
    this.createdByName,
    this.ingredients = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    htmlContent,
    description,
    foodName,
    imageUrl,
    foodId,
    isPublic,
    groupId,
    groupName,
    createdByName,
    ingredients,
  ];
}
