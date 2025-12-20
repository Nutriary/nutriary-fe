import 'package:equatable/equatable.dart';

class ShoppingTask extends Equatable {
  final int id;
  final String foodName;
  final String quantity;
  final bool isBought;
  final int orderIndex;
  final String? imageUrl;
  final int? foodId;

  const ShoppingTask({
    required this.id,
    required this.foodName,
    required this.quantity,
    required this.isBought,
    required this.orderIndex,
    this.imageUrl,
    this.foodId,
  });

  @override
  List<Object?> get props => [
    id,
    foodName,
    quantity,
    isBought,
    orderIndex,
    imageUrl,
    foodId,
  ];

  ShoppingTask copyWith({
    int? id,
    String? foodName,
    String? quantity,
    bool? isBought,
    int? orderIndex,
    String? imageUrl,
    int? foodId,
  }) {
    return ShoppingTask(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
      orderIndex: orderIndex ?? this.orderIndex,
      imageUrl: imageUrl ?? this.imageUrl,
      foodId: foodId ?? this.foodId,
    );
  }
}
