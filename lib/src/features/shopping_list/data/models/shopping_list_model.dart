import '../../domain/entities/shopping_list.dart';

class ShoppingListModel extends ShoppingListEntity {
  const ShoppingListModel({
    required super.id,
    required super.name,
    super.note,
    super.date,
    super.groupId,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'],
      name: json['name'] ?? 'Unnamed List',
      note: json['note'],
      date: json['date'],
      groupId: json['groupId'],
    );
  }
}
