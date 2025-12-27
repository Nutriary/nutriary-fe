import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/food_model.dart';

abstract class FoodRemoteDataSource {
  Future<List<FoodModel>> getFoods();
  Future<void> createFood({
    required String name,
    required String category,
    required String unit,
    File? image,
  });
  Future<void> updateFood({
    required String name,
    String? newCategory,
    String? newUnit,
    File? image,
  });
  Future<void> deleteFood(String name);
}

@LazySingleton(as: FoodRemoteDataSource)
class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final Dio _dio;
  FoodRemoteDataSourceImpl(this._dio);

  @override
  Future<List<FoodModel>> getFoods() async {
    try {
      final response = await _dio.get('/food', queryParameters: {'size': 1000});
      // Backend returns: { "data": { "data": [List of foods], "totalItems": ... } }
      // So response.data['data'] is a Map (PaginatedResult).
      // We need response.data['data']['data']
      final responseData = response.data['data'];
      List list;
      if (responseData is Map && responseData.containsKey('data')) {
        list = responseData['data'] as List;
      } else if (responseData is List) {
        list = responseData;
      } else {
        list = [];
      }

      return list.map((json) => FoodModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> createFood({
    required String name,
    required String category,
    required String unit,
    File? image,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'foodCategoryName': category,
      'unitName': unit,
    });

    if (image != null) {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(image.path)),
      );
    }

    await _dio.post('/food', data: formData);
  }

  @override
  Future<void> updateFood({
    required String name,
    String? newCategory,
    String? newUnit,
    File? image,
  }) async {
    final formData = FormData.fromMap({'name': name});

    if (newCategory != null) {
      formData.fields.add(MapEntry('newCategory', newCategory));
    }
    if (newUnit != null) {
      formData.fields.add(MapEntry('newUnit', newUnit));
    }
    if (image != null) {
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(image.path)),
      );
    }

    await _dio.put('/food', data: formData);
  }

  @override
  Future<void> deleteFood(String name) async {
    await _dio.delete('/food/$name');
  }
}
