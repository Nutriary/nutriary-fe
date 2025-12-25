import 'package:equatable/equatable.dart';

class ShoppingTask extends Equatable {
  final int id;
  final String foodName;
  final String quantity;
  final bool isBought;
  final int orderIndex;
  final String? imageUrl;
  final int? foodId;
  // Assignee info
  final int? assigneeId;
  final String? assigneeName;
  final String? assigneeAvatarUrl;

  const ShoppingTask({
    required this.id,
    required this.foodName,
    required this.quantity,
    required this.isBought,
    required this.orderIndex,
    this.imageUrl,
    this.foodId,
    this.assigneeId,
    this.assigneeName,
    this.assigneeAvatarUrl,
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
    assigneeId,
    assigneeName,
    assigneeAvatarUrl,
  ];

  ShoppingTask copyWith({
    int? id,
    String? foodName,
    String? quantity,
    bool? isBought,
    int? orderIndex,
    String? imageUrl,
    int? foodId,
    int? assigneeId,
    String? assigneeName,
    String? assigneeAvatarUrl,
  }) {
    return ShoppingTask(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
      orderIndex: orderIndex ?? this.orderIndex,
      imageUrl: imageUrl ?? this.imageUrl,
      foodId: foodId ?? this.foodId,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeAvatarUrl: assigneeAvatarUrl ?? this.assigneeAvatarUrl,
    );
  }
}
