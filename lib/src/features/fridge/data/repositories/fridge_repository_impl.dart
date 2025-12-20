import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/fridge_item.dart';
import '../../domain/repositories/fridge_repository.dart';
import '../models/fridge_item_model.dart';

abstract class FridgeRemoteDataSource {
  Future<List<FridgeItemModel>> getFridgeItems(int? groupId);
  Future<void> addFridgeItem({
    required String foodName,
    required String quantity,
    DateTime? useWithin,
    String? categoryName,
    int? groupId,
  });
  Future<void> updateFridgeItem({
    required String foodName,
    String? quantity,
    DateTime? useWithin,
    int? groupId,
  });
  Future<void> removeFridgeItem(String foodName, int? groupId);
}

@LazySingleton(as: FridgeRemoteDataSource)
class FridgeRemoteDataSourceImpl implements FridgeRemoteDataSource {
  final Dio _dio;
  FridgeRemoteDataSourceImpl(this._dio);

  @override
  Future<List<FridgeItemModel>> getFridgeItems(int? groupId) async {
    final response = await _dio.get(
      '/fridge',
      queryParameters: {
        'page': 1,
        'size': 100, // Or implement pagination later
        if (groupId != null) 'groupId': groupId,
      },
    );
    final responseData = response.data['data'];
    if (responseData is Map && responseData.containsKey('data')) {
      return (responseData['data'] as List<dynamic>)
          .map((e) => FridgeItemModel.fromJson(e))
          .toList();
    }
    return (responseData as List<dynamic>?)
            ?.map((e) => FridgeItemModel.fromJson(e))
            .toList() ??
        [];
  }

  @override
  Future<void> addFridgeItem({
    required String foodName,
    required String quantity,
    DateTime? useWithin,
    String? categoryName,
    int? groupId,
  }) async {
    await _dio.post(
      '/fridge',
      data: {
        'foodName': foodName,
        'quantity': num.tryParse(quantity) ?? 1,
        if (useWithin != null) 'useWithin': useWithin.toIso8601String(),
        if (categoryName != null) 'categoryName': categoryName,
        if (groupId != null) 'groupId': groupId,
      },
    );
  }

  @override
  Future<void> updateFridgeItem({
    required String foodName,
    String? quantity,
    DateTime? useWithin,
    int? groupId,
  }) async {
    final data = <String, dynamic>{'foodName': foodName};
    if (quantity != null) data['quantity'] = num.tryParse(quantity) ?? 1;
    if (useWithin != null) data['useWithin'] = useWithin.toIso8601String();
    if (groupId != null) data['groupId'] = groupId;

    await _dio.put('/fridge', data: data);
  }

  @override
  Future<void> removeFridgeItem(String foodName, int? groupId) async {
    await _dio.delete(
      '/fridge',
      data: {'foodName': foodName, if (groupId != null) 'groupId': groupId},
    );
  }
}

@LazySingleton(as: FridgeRepository)
class FridgeRepositoryImpl implements FridgeRepository {
  final FridgeRemoteDataSource _dataSource;
  FridgeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<FridgeItem>>> getFridgeItems(int? groupId) async {
    try {
      final result = await _dataSource.getFridgeItems(groupId);
      return Right(result);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to fetch items'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFridgeItem({
    required String foodName,
    required String quantity,
    DateTime? useWithin,
    String? categoryName,
    int? groupId,
  }) async {
    try {
      await _dataSource.addFridgeItem(
        foodName: foodName,
        quantity: quantity,
        useWithin: useWithin,
        categoryName: categoryName,
        groupId: groupId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to add item'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFridgeItem({
    required String foodName,
    String? quantity,
    DateTime? useWithin,
    int? groupId,
  }) async {
    try {
      await _dataSource.updateFridgeItem(
        foodName: foodName,
        quantity: quantity,
        useWithin: useWithin,
        groupId: groupId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to update item'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFridgeItem(
    String foodName,
    int? groupId,
  ) async {
    try {
      await _dataSource.removeFridgeItem(foodName, groupId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to remove item'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
