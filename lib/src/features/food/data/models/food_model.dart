import '../../domain/entities/food.dart';

class FoodModel extends Food {
  const FoodModel({
    required super.name,
    super.imageUrl,
    required super.category,
    required super.unit,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      name: json['name'],
      imageUrl: json['image'],
      category: json['category'] is Map
          ? json['category']['name']
          : (json['category'] ?? ''),
      unit: json['unit'] is Map ? json['unit']['name'] : (json['unit'] ?? ''),
    );
  }
}
