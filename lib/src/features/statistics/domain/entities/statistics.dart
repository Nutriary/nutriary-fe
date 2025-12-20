import 'package:equatable/equatable.dart';

class ConsumptionStat extends Equatable {
  final String action;
  final String foodName;
  final double totalQuantity;
  final int count;

  const ConsumptionStat({
    required this.action,
    required this.foodName,
    required this.totalQuantity,
    required this.count,
  });

  @override
  List<Object?> get props => [action, foodName, totalQuantity, count];
}

class ShoppingStat extends Equatable {
  final String foodName;
  final double totalQuantity;

  const ShoppingStat({required this.foodName, required this.totalQuantity});

  @override
  List<Object?> get props => [foodName, totalQuantity];
}
