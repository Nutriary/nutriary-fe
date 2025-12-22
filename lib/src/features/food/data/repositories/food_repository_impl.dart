import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/food_remote_data_source.dart';

@LazySingleton(as: FoodRepository)
class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource _dataSource;

  FoodRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Food>>> getFoods() async {
    try {
      final models = await _dataSource.getFoods();
      return Right(models);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createFood({
    required String name,
    required String category,
    required String unit,
    File? image,
  }) async {
    try {
      await _dataSource.createFood(
        name: name,
        category: category,
        unit: unit,
        image: image,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFood({
    required String name,
    String? newCategory,
    String? newUnit,
    File? image,
  }) async {
    try {
      await _dataSource.updateFood(
        name: name,
        newCategory: newCategory,
        newUnit: newUnit,
        image: image,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFood(String name) async {
    try {
      await _dataSource.deleteFood(name);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
