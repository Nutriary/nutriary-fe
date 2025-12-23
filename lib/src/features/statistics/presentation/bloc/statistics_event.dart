import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();
  @override
  List<Object?> get props => [];
}

class LoadConsumptionStats extends StatisticsEvent {
  final String? from;
  final String? to;
  final int? groupId;
  const LoadConsumptionStats({this.from, this.to, this.groupId});
  @override
  List<Object?> get props => [from, to, groupId];
}

class LoadShoppingStats extends StatisticsEvent {
  final String? from;
  final String? to;
  final int? groupId;
  const LoadShoppingStats({this.from, this.to, this.groupId});
  @override
  List<Object?> get props => [from, to, groupId];
}
