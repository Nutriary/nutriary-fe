import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/unit.dart';
import '../../domain/repositories/unit_repository.dart';

abstract class UnitRemoteDataSource {
  Future<List<String>> getUnits();
  Future<void> createUnit(String name);
  Future<void> updateUnit(String oldName, String newName);
  Future<void> deleteUnit(String name);
}

@LazySingleton(as: UnitRemoteDataSource)
class UnitRemoteDataSourceImpl implements UnitRemoteDataSource {
  final Dio _dio;
  UnitRemoteDataSourceImpl(this._dio);

  @override
  Future<List<String>> getUnits() async {
    try {
      final response = await _dio.get('/admin/unit');
      final data = response.data['data'];
      // Handle different possible structures
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).map((e) => e['name'].toString()).toList();
      } else if (data is List) {
        return data.map((e) => e['name'].toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> createUnit(String name) async {
    await _dio.post('/admin/unit', data: {'unitName': name});
  }

  @override
  Future<void> updateUnit(String oldName, String newName) async {
    await _dio.put(
      '/admin/unit',
      data: {'oldName': oldName, 'newName': newName},
    );
  }

  @override
  Future<void> deleteUnit(String name) async {
    await _dio.delete('/admin/unit', data: {'unitName': name});
  }
}

@LazySingleton(as: UnitRepository)
class UnitRepositoryImpl implements UnitRepository {
  final UnitRemoteDataSource _dataSource;
  UnitRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<UnitEntity>>> getUnits() async {
    try {
      final names = await _dataSource.getUnits();
      return Right(names.map((name) => UnitEntity(name: name)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createUnit(String name) async {
    try {
      await _dataSource.createUnit(name);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUnit(
    String oldName,
    String newName,
  ) async {
    try {
      await _dataSource.updateUnit(oldName, newName);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUnit(String name) async {
    try {
      await _dataSource.deleteUnit(name);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
