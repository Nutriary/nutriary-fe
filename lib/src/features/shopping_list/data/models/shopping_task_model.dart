import '../../domain/entities/shopping_task.dart';

class ShoppingTaskModel extends ShoppingTask {
  const ShoppingTaskModel({
    required super.id,
    required super.foodName,
    required super.quantity,
    required super.isBought,
    required super.orderIndex,
    super.imageUrl,
    super.foodId,
  });

  factory ShoppingTaskModel.fromJson(Map<String, dynamic> json) {
    final food = json['food'];
    return ShoppingTaskModel(
      id: json['id'],
      foodName: food != null ? food['name'] : (json['foodName'] ?? 'Unknown'),
      quantity: json['quantity']?.toString() ?? '1',
      isBought: json['isBought'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
      imageUrl: food != null ? food['foodImageUrl'] : null,
      foodId: food != null ? food['id'] : null,
    );
  }
}
