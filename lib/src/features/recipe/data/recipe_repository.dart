import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriary_fe/src/features/auth/data/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_repository.g.dart';

@riverpod
RecipeRepository recipeRepository(Ref ref) {
  return RecipeRepository(ref.watch(dioProvider));
}

class RecipeRepository {
  final Dio _dio;

  RecipeRepository(this._dio);

  Future<List<dynamic>> getAllRecipes() async {
    try {
      final response = await _dio.get('/recipe/all');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch recipes';
    }
  }

  Future<List<dynamic>> getRecipesByFood(int foodId) async {
    try {
      final response = await _dio.get('/recipe', queryParameters: {'foodId': foodId});
      return response.data as List<dynamic>;
    } on DioException catch (e) {
       throw e.response?.data['message'] ?? 'Failed to fetch recipes for food';
    }
  }
}
