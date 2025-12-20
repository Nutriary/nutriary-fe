import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../models/statistics_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<List<ConsumptionStatModel>> getConsumptionStats(
    String? from,
    String? to,
  );
  Future<List<ShoppingStatModel>> getShoppingStats(String? from, String? to);
}

@LazySingleton(as: StatisticsRemoteDataSource)
class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final Dio _dio;
  StatisticsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ConsumptionStatModel>> getConsumptionStats(
    String? from,
    String? to,
  ) async {
    final response = await _dio.get(
      '/statistics/consumption',
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => ConsumptionStatModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<List<ShoppingStatModel>> getShoppingStats(
    String? from,
    String? to,
  ) async {
    final response = await _dio.get(
      '/statistics/shopping',
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
      },
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => ShoppingStatModel.fromJson(e)).toList();
    }
    return [];
  }
}

@LazySingleton(as: StatisticsRepository)
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource _dataSource;
  StatisticsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ConsumptionStat>>> getConsumptionStats(
    String? from,
    String? to,
  ) async {
    try {
      final result = await _dataSource.getConsumptionStats(from, to);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Failed to load consumption stats',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShoppingStat>>> getShoppingStats(
    String? from,
    String? to,
  ) async {
    try {
      final result = await _dataSource.getShoppingStats(from, to);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Failed to load shopping stats',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
