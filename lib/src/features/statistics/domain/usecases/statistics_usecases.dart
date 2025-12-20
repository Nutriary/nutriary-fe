import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/statistics.dart';
import '../repositories/statistics_repository.dart';

class StatisticsParams extends Equatable {
  final String? from;
  final String? to;
  const StatisticsParams({this.from, this.to});
  @override
  List<Object?> get props => [from, to];
}

@lazySingleton
class GetConsumptionStatsUseCase
    extends UseCase<List<ConsumptionStat>, StatisticsParams> {
  final StatisticsRepository repository;
  GetConsumptionStatsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ConsumptionStat>>> call(
    StatisticsParams params,
  ) => repository.getConsumptionStats(params.from, params.to);
}

@lazySingleton
class GetShoppingStatsUseCase
    extends UseCase<List<ShoppingStat>, StatisticsParams> {
  final StatisticsRepository repository;
  GetShoppingStatsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ShoppingStat>>> call(StatisticsParams params) =>
      repository.getShoppingStats(params.from, params.to);
}
