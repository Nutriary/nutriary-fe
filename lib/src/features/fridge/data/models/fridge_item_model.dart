import '../../domain/entities/fridge_item.dart';

class FridgeItemModel extends FridgeItem {
  const FridgeItemModel({
    required super.id,
    required super.foodName,
    required super.categoryName,
    required super.quantity,
    super.useWithin,
    super.imageUrl,
  });

  factory FridgeItemModel.fromJson(Map<String, dynamic> json) {
    final food = json['food'] ?? {};
    final category = food['category'] ?? {};

    // Parse quantity - MySQL decimal comes as string
    final rawQuantity = json['quantity'];
    final quantity = rawQuantity is num
        ? rawQuantity
        : (rawQuantity is String ? num.tryParse(rawQuantity) ?? 1 : 1);

    return FridgeItemModel(
      id: json['id'],
      foodName: food['name'] ?? json['foodName'] ?? 'Unknown',
      categoryName: category['name'] ?? 'Khác',
      quantity: quantity,
      useWithin: json['use_within'] != null
          ? DateTime.tryParse(json['use_within'])
          : (json['useWithin'] != null
                ? DateTime.tryParse(json['useWithin'])
                : null),
      imageUrl: food['foodImageUrl'],
    );
  }
}
