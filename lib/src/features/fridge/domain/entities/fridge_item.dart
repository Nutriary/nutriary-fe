import 'package:equatable/equatable.dart';

class FridgeItem extends Equatable {
  final int id;
  final String foodName;
  final String categoryName;
  final String unitName;
  final num quantity;
  final DateTime? useWithin;
  final String? imageUrl;

  const FridgeItem({
    required this.id,
    required this.foodName,
    required this.categoryName,
    required this.unitName,
    required this.quantity,
    this.useWithin,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    foodName,
    categoryName,
    unitName,
    quantity,
    useWithin,
    imageUrl,
  ];
}
