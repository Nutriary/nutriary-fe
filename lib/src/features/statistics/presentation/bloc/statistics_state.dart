import 'package:equatable/equatable.dart';
import '../../domain/entities/statistics.dart';

enum StatisticsStatus { initial, loading, success, failure }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final List<ConsumptionStat> consumptionStats;
  final List<ShoppingStat> shoppingStats;
  final String? errorMessage;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.consumptionStats = const [],
    this.shoppingStats = const [],
    this.errorMessage,
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    List<ConsumptionStat>? consumptionStats,
    List<ShoppingStat>? shoppingStats,
    String? errorMessage,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      consumptionStats: consumptionStats ?? this.consumptionStats,
      shoppingStats: shoppingStats ?? this.shoppingStats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    consumptionStats,
    shoppingStats,
    errorMessage,
  ];
}
