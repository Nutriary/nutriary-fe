import 'package:equatable/equatable.dart';

abstract class FridgeEvent extends Equatable {
  const FridgeEvent();
  @override
  List<Object?> get props => [];
}

class LoadFridgeItems extends FridgeEvent {
  final int? groupId;
  const LoadFridgeItems(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class LoadCategories extends FridgeEvent {}

class ChangeFilter extends FridgeEvent {
  final String filter; // 'All', 'Expiring'
  const ChangeFilter(this.filter);
  @override
  List<Object?> get props => [filter];
}

class SearchFridgeItems extends FridgeEvent {
  final String query;
  const SearchFridgeItems(this.query);
  @override
  List<Object?> get props => [query];
}

class AddItem extends FridgeEvent {
  final String foodName;
  final String quantity;
  final DateTime? useWithin;
  final String? categoryName;
  final String? unitName;
  final int? groupId;

  const AddItem({
    required this.foodName,
    required this.quantity,
    this.useWithin,
    this.categoryName,
    this.unitName,
    this.groupId,
  });
  @override
  List<Object?> get props => [
    foodName,
    quantity,
    useWithin,
    categoryName,
    unitName,
    groupId,
  ];
}

class UpdateItem extends FridgeEvent {
  final String foodName;
  final String? quantity;
  final DateTime? useWithin;
  final int? groupId;

  const UpdateItem({
    required this.foodName,
    this.quantity,
    this.useWithin,
    this.groupId,
  });
  @override
  List<Object?> get props => [foodName, quantity, useWithin, groupId];
}

class RemoveItem extends FridgeEvent {
  final String foodName;
  final int? groupId;
  const RemoveItem(this.foodName, this.groupId);
  @override
  List<Object?> get props => [foodName, groupId];
}

class ConsumeItem extends FridgeEvent {
  final String foodName;
  final double quantity;
  final int? groupId;
  const ConsumeItem({
    required this.foodName,
    required this.quantity,
    this.groupId,
  });
  @override
  List<Object?> get props => [foodName, quantity, groupId];
}
