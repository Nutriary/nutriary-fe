import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriary_fe/src/features/auth/data/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'shopping_repository.g.dart';

@riverpod
ShoppingRepository shoppingRepository(Ref ref) {
  return ShoppingRepository(ref.watch(dioProvider));
}

class ShoppingRepository {
  final Dio _dio;
  ShoppingRepository(this._dio);

  Future<void> _addAuthHeader() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Get Shopping Lists (Uses Group ID, but backend maybe infers from user? Controller has no getLists??)
  // Wait, I didn't see a getLists endpoint in ShoppingListController.ts!!
  // Let me re-read ShoppingListController.ts content from previous turn.
  // It has create, addTask, updateList, deleteList, getTasks.
  // WHERE IS GET LISTS?
  // I must check the backend again. Maybe I missed it or it's in another controller (GroupController?).
  // Group entity has OneToMany shoppingLists.
  // So probably getGroup returns the lists?
  // I will assume for now getGroup includes lists, or I need to find the endpoint.
  // Re-reading GroupController: getGroup returns service.getMyGroup.
  // checking functionality in next step. For now writing what I know.

  Future<List<dynamic>> getTasks(String listId) async {
    await _addAuthHeader();
    try {
      final response = await _dio.get(
        '/shopping/task',
        queryParameters: {'listId': listId},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch tasks';
    }
  }

  Future<void> createList(String name, String? note, String? date) async {
    await _addAuthHeader();
    try {
      await _dio.post(
        '/shopping',
        data: {'name': name, 'note': note, 'date': date},
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create list';
    }
  }

  Future<void> addTask(int listId, String foodName, String quantity) async {
    await _addAuthHeader();
    try {
      await _dio.post(
        '/shopping/task',
        data: {
          'listId': listId,
          'tasks': [
            {'foodName': foodName, 'quantity': quantity},
          ],
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to add task';
    }
  }

  Future<void> updateTask(
    int taskId, {
    bool? isBought,
    String? quantity,
  }) async {
    await _addAuthHeader();
    try {
      final data = <String, dynamic>{'taskId': taskId};
      if (isBought != null) data['isBought'] = isBought;
      if (quantity != null) data['newQuantity'] = quantity;

      await _dio.put('/shopping/task', data: data);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to update task';
    }
  }

  Future<void> reorderTasks(List<dynamic> items) async {
    await _addAuthHeader();
    try {
      // Backend expects { items: [{ id: 1, orderIndex: 0 }] }
      final payload = items
          .asMap()
          .entries
          .map((e) => {'id': e.value['id'], 'orderIndex': e.key})
          .toList();
      await _dio.put('/shopping/task/reorder', data: {'items': payload});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to reorder';
    }
  }

  Future<void> deleteTask(int taskId) async {
    await _addAuthHeader();
    try {
      await _dio.delete('/shopping/task', data: {'taskId': taskId});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete task';
    }
  }
}
