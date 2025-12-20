import '../../domain/entities/statistics.dart';

class ConsumptionStatModel extends ConsumptionStat {
  const ConsumptionStatModel({
    required super.action,
    required super.foodName,
    required super.totalQuantity,
    required super.count,
  });

  factory ConsumptionStatModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionStatModel(
      action: json['log_action'] ?? json['action'] ?? 'unknown',
      foodName: json['log_foodName'] ?? json['foodName'] ?? 'Unknown',
      totalQuantity:
          double.tryParse(json['totalQuantity']?.toString() ?? '0') ?? 0,
      count: int.tryParse(json['count']?.toString() ?? '0') ?? 0,
    );
  }
}

class ShoppingStatModel extends ShoppingStat {
  const ShoppingStatModel({
    required super.foodName,
    required super.totalQuantity,
  });

  factory ShoppingStatModel.fromJson(Map<String, dynamic> json) {
    return ShoppingStatModel(
      foodName: json['food_name'] ?? json['name'] ?? 'Unknown',
      totalQuantity:
          double.tryParse(json['totalQuantity']?.toString() ?? '0') ?? 0,
    );
  }
}
