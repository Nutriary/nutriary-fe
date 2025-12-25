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
    super.assigneeId,
    super.assigneeName,
    super.assigneeAvatarUrl,
  });

  factory ShoppingTaskModel.fromJson(Map<String, dynamic> json) {
    final food = json['food'];
    final assignee = json['assignee'];
    return ShoppingTaskModel(
      id: json['id'],
      foodName: food != null ? food['name'] : (json['foodName'] ?? 'Unknown'),
      quantity: json['quantity']?.toString() ?? '1',
      isBought: json['isBought'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
      imageUrl: food != null ? food['foodImageUrl'] : null,
      foodId: food != null ? food['id'] : null,
      assigneeId: assignee != null ? assignee['id'] : null,
      assigneeName: assignee != null ? assignee['name'] : null,
      assigneeAvatarUrl: assignee != null ? assignee['avatarUrl'] : null,
    );
  }
}
