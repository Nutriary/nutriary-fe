import 'package:equatable/equatable.dart';

class SystemStats extends Equatable {
  final int users;
  final int groups;
  final int recipes;
  final int shoppingLists;

  const SystemStats({
    required this.users,
    required this.groups,
    required this.recipes,
    required this.shoppingLists,
  });

  @override
  List<Object?> get props => [users, groups, recipes, shoppingLists];
}
