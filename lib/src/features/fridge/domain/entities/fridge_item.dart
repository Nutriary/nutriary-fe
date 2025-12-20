import 'package:equatable/equatable.dart';

class FridgeItem extends Equatable {
  final int id;
  final String foodName;
  final String categoryName;
  final num quantity;
  final DateTime? useWithin;
  final String? imageUrl;

  const FridgeItem({
    required this.id,
    required this.foodName,
    required this.categoryName,
    required this.quantity,
    this.useWithin,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    foodName,
    categoryName,
    quantity,
    useWithin,
    imageUrl,
  ];
}
