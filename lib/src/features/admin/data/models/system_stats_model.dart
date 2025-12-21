import '../../domain/entities/system_stats.dart';

class SystemStatsModel extends SystemStats {
  const SystemStatsModel({
    required super.users,
    required super.groups,
    required super.recipes,
    required super.shoppingLists,
  });

  factory SystemStatsModel.fromJson(Map<String, dynamic> json) {
    return SystemStatsModel(
      users: json['users'] ?? 0,
      groups: json['groups'] ?? 0,
      recipes: json['recipes'] ?? 0,
      shoppingLists: json['orders'] ?? 0,
    );
  }
}
