import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/category_repository.dart';

abstract class CategoryRemoteDataSource {
  Future<List<String>> getCategories();
  Future<void> createCategory(String name);
  Future<void> updateCategory(String oldName, String newName);
  Future<void> deleteCategory(String name);
}

@LazySingleton(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio _dio;
  CategoryRemoteDataSourceImpl(this._dio);

  @override
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/admin/category');
      final data = response.data['data'];
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
  Future<void> createCategory(String name) async {
    await _dio.post('/admin/category', data: {'name': name});
  }

  @override
  Future<void> updateCategory(String oldName, String newName) async {
    await _dio.put(
      '/admin/category',
      data: {'oldName': oldName, 'newName': newName},
    );
  }

  @override
  Future<void> deleteCategory(String name) async {
    await _dio.delete('/admin/category', data: {'name': name});
  }
}

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _dataSource;
  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final result = await _dataSource.getCategories();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createCategory(String name) async {
    try {
      await _dataSource.createCategory(name);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(
    String oldName,
    String newName,
  ) async {
    try {
      await _dataSource.updateCategory(oldName, newName);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String name) async {
    try {
      await _dataSource.deleteCategory(name);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
