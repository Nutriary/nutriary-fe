import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriary_fe/src/features/auth/data/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fridge_repository.g.dart';

@riverpod
FridgeRepository fridgeRepository(Ref ref) {
  return FridgeRepository(ref.watch(dioProvider));
}

class FridgeRepository {
  final Dio _dio;

  FridgeRepository(this._dio);

  Future<List<dynamic>> getFridgeItems() async {
    try {
      final response = await _dio.get('/fridge');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch fridge items';
    }
  }

  Future<void> addFridgeItem(String foodName, String quantity, DateTime? useWithin) async {
    try {
      await _dio.post('/fridge', data: {
        'foodName': foodName,
        'quantity': quantity,
        if (useWithin != null) 'useWithin': useWithin.toIso8601String(),
      });
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to add item';
    }
  }

  Future<void> removeFridgeItem(String foodName) async {
    try {
      await _dio.delete('/fridge', data: {'foodName': foodName});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to remove item';
    }
  }
}
