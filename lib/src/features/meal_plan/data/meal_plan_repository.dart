import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriary_fe/src/features/auth/data/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meal_plan_repository.g.dart';

@riverpod
MealPlanRepository mealPlanRepository(Ref ref) {
  return MealPlanRepository(ref.watch(dioProvider));
}

class MealPlanRepository {
  final Dio _dio;

  MealPlanRepository(this._dio);

  Future<List<dynamic>> getMealPlan(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0];
      final response = await _dio.get(
        '/meal',
        queryParameters: {'date': formattedDate},
      );
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to fetch meal plan';
    }
  }

  Future<void> addMealPlan(
    DateTime date,
    String mealType,
    String foodName,
    int? recipeId,
  ) async {
    try {
      await _dio.post(
        '/meal',
        data: {
          'name': mealType,
          'foodName': foodName,
          'timestamp': date.toIso8601String(), // Service expects timestamp
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to add meal';
    }
  }

  Future<void> deleteMealPlan(int id) async {
    try {
      await _dio.delete(
        '/meal',
        data: {'planId': id},
      ); // Controller uses DeleteMealPlanDto with planId (Step 751 line 50)
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to delete meal';
    }
  }

  Future<List<dynamic>> getSuggestions() async {
    try {
      final response = await _dio.get('/meal/suggest');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Failed to get suggestions';
    }
  }
}
