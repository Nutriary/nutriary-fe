import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadConsumptionStats extends StatisticsEvent {
  final String? from;
  final String? to;
  const LoadConsumptionStats({this.from, this.to});
  @override
  List<Object?> get props => [from, to];
}

class LoadShoppingStats extends StatisticsEvent {
  final String? from;
  final String? to;
  const LoadShoppingStats({this.from, this.to});
  @override
  List<Object?> get props => [from, to];
}
