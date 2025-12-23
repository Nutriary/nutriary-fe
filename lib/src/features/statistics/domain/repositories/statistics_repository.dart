import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/statistics.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, List<ConsumptionStat>>> getConsumptionStats(
    String? from,
    String? to,
    int? groupId,
  );
  Future<Either<Failure, List<ShoppingStat>>> getShoppingStats(
    String? from,
    String? to,
    int? groupId,
  );
}
