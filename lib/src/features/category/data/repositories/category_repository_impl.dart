import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/category_repository.dart';

abstract class CategoryRemoteDataSource {
  Future<List<String>> getCategories();
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
      // Handle { data: [...] } or { data: { data: [...] } }
      // Legacy code said: (data['data'] as List).map((e) => e['name'] as String).toList();
      // Assuming legacy checks were correct about structure.
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
}
