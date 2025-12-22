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
    final response = await _dio.get('/food');
    final data = response.data['data'] as List;
    return data.map((json) => FoodModel.fromJson(json)).toList();
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
