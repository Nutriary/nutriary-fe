import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/entities/shopping_task.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../models/shopping_list_model.dart';
import '../models/shopping_task_model.dart';

abstract class ShoppingRemoteDataSource {
  Future<List<ShoppingListModel>> getShoppingLists(int? groupId);
  Future<void> createShoppingList(String name, String? note, int? groupId);
  Future<List<ShoppingTaskModel>> getTasks(int listId);
  Future<void> addTask(int listId, String foodName, String quantity);
  Future<void> updateTask(int taskId, bool? isBought, String? quantity);
  Future<void> deleteTask(int taskId);
  Future<void> reorderTasks(List<ShoppingTask> tasks);
}

@LazySingleton(as: ShoppingRemoteDataSource)
class ShoppingRemoteDataSourceImpl implements ShoppingRemoteDataSource {
  final Dio _dio;
  ShoppingRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ShoppingListModel>> getShoppingLists(int? groupId) async {
    final response = await _dio.get(
      '/shopping',
      queryParameters: {if (groupId != null) 'groupId': groupId},
    );
    final data = response.data['data'] as List?;
    return data?.map((e) => ShoppingListModel.fromJson(e)).toList() ?? [];
  }

  @override
  Future<void> createShoppingList(
    String name,
    String? note,
    int? groupId,
  ) async {
    await _dio.post(
      '/shopping',
      data: {
        'name': name,
        'note': note,
        if (groupId != null) 'groupId': groupId,
      },
    );
  }

  @override
  Future<List<ShoppingTaskModel>> getTasks(int listId) async {
    final response = await _dio.get(
      '/shopping/task',
      queryParameters: {'listId': listId},
    );
    final responseData = response.data['data'];
    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      return (responseData['data'] as List)
          .map((e) => ShoppingTaskModel.fromJson(e))
          .toList();
    }
    return [];
  }

  @override
  Future<void> addTask(int listId, String foodName, String quantity) async {
    await _dio.post(
      '/shopping/task',
      data: {
        'listId': listId,
        'tasks': [
          {'foodName': foodName, 'quantity': quantity},
        ],
      },
    );
  }

  @override
  Future<void> updateTask(int taskId, bool? isBought, String? quantity) async {
    final data = <String, dynamic>{'taskId': taskId};
    if (isBought != null) data['isBought'] = isBought;
    if (quantity != null) data['newQuantity'] = quantity;

    await _dio.put('/shopping/task', data: data);
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await _dio.delete('/shopping/task', data: {'taskId': taskId});
  }

  @override
  Future<void> reorderTasks(List<ShoppingTask> tasks) async {
    final payload = tasks
        .asMap()
        .entries
        .map(
          (e) => {'id': e.value.id, 'orderIndex': e.key},
        ) // e.key is index from UI logic
        .toList();
    // Wait, e.key is just loop index. The UseCase passes the list in new order.
    // So yes, using logical index for orderIndex.

    await _dio.put('/shopping/task/reorder', data: {'items': payload});
  }
}

@LazySingleton(as: ShoppingRepository)
class ShoppingRepositoryImpl implements ShoppingRepository {
  final ShoppingRemoteDataSource _dataSource;
  ShoppingRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ShoppingListEntity>>> getShoppingLists(
    int? groupId,
  ) async {
    try {
      final result = await _dataSource.getShoppingLists(groupId);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to get lists'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createShoppingList(
    String name,
    String? note,
    int? groupId,
  ) async {
    try {
      await _dataSource.createShoppingList(name, note, groupId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to create list'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShoppingTask>>> getTasks(int listId) async {
    try {
      final result = await _dataSource.getTasks(listId);
      // Sort items by orderIndex? Or rely on backend?
      // Backend usually returns in DB order, but better to sort client side if 'orderIndex' is used.
      result.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to get tasks'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTask({
    required int listId,
    required String foodName,
    required String quantity,
  }) async {
    try {
      await _dataSource.addTask(listId, foodName, quantity);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to add task'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTask({
    required int taskId,
    bool? isBought,
    String? quantity,
  }) async {
    try {
      await _dataSource.updateTask(taskId, isBought, quantity);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to update task'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(int taskId) async {
    try {
      await _dataSource.deleteTask(taskId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to delete task'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorderTasks(List<ShoppingTask> tasks) async {
    try {
      await _dataSource.reorderTasks(tasks);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to reorder'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
