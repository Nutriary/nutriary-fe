import '../../domain/entities/group.dart';
import 'package:nutriary_fe/src/features/shopping_list/data/models/shopping_list_model.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    super.shoppingLists = const [],
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final shoppingListsJson = json['shoppingLists'] as List<dynamic>?;
    final shoppingLists =
        shoppingListsJson
            ?.map((e) => ShoppingListModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return GroupModel(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Group',
      shoppingLists: shoppingLists,
    );
  }
}
