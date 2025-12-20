import 'package:equatable/equatable.dart';
import 'package:nutriary_fe/src/features/shopping_list/domain/entities/shopping_list.dart';

class Group extends Equatable {
  final int id;
  final String name;
  final List<ShoppingListEntity> shoppingLists;

  const Group({
    required this.id,
    required this.name,
    this.shoppingLists = const [],
  });

  @override
  List<Object?> get props => [id, name, shoppingLists];
}
