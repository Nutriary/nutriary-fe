import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../models/meal_plan_model.dart';

abstract class MealPlanRemoteDataSource {
  Future<List<MealPlanModel>> getMealPlan(DateTime date);
  Future<void> addMealPlan(
    DateTime date,
    String mealType,
    String foodName,
    int? recipeId,
  );
  Future<void> deleteMealPlan(int id);
  Future<List<String>> getSuggestions();
}

@LazySingleton(as: MealPlanRemoteDataSource)
class MealPlanRemoteDataSourceImpl implements MealPlanRemoteDataSource {
  final Dio _dio;
  MealPlanRemoteDataSourceImpl(this._dio);

  static const _mealTypeToApi = {
    'Bữa Sáng': 'Breakfast',
    'Bữa Trưa': 'Lunch',
    'Bữa Tối': 'Dinner',
    'Bữa Phụ': 'Snack',
  };

  static const _apiToMealType = {
    'Breakfast': 'Bữa Sáng',
    'Lunch': 'Bữa Trưa',
    'Dinner': 'Bữa Tối',
    'Snack': 'Bữa Phụ',
    'breakfast': 'Bữa Sáng',
    'lunch': 'Bữa Trưa',
    'dinner': 'Bữa Tối',
    'snack': 'Bữa Phụ',
  };

  @override
  Future<List<MealPlanModel>> getMealPlan(DateTime date) async {
    final formattedDate = date.toIso8601String().split('T')[0];
    final response = await _dio.get(
      '/meal',
      queryParameters: {'date': formattedDate},
    );
    final responseData = response.data['data'];
    List<dynamic> list = [];
    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      list = responseData['data'] as List<dynamic>;
    } else {
      list = (responseData as List?) ?? [];
    }

    return list.map((item) {
      // Map mealType before creating model or inside model?
      // Model expects 'name' from JSON to be raw from API.
      // We can map fields here or just return Model and let Repo handle mapping?
      // Legacy code returned mapped list.
      // If we map here, we change the 'name' field in JSON.
      final apiType = item['name'] as String? ?? '';
      final uiType = _apiToMealType[apiType] ?? apiType;
      final newItem = Map<String, dynamic>.from(item);
      newItem['name'] =
          uiType; // Inject mapped type so Model.fromJson reads it as mealType
      return MealPlanModel.fromJson(newItem);
    }).toList();
  }

  @override
  Future<void> addMealPlan(
    DateTime date,
    String mealType,
    String foodName,
    int? recipeId,
  ) async {
    final apiType = _mealTypeToApi[mealType] ?? mealType;
    await _dio.post(
      '/meal',
      data: {
        'name': apiType,
        'foodName': foodName,
        'timestamp': date.toIso8601String(),
        if (recipeId != null) 'recipeId': recipeId,
      },
    );
  }

  @override
  Future<void> deleteMealPlan(int id) async {
    await _dio.delete('/meal', data: {'planId': id});
  }

  @override
  Future<List<String>> getSuggestions() async {
    final response = await _dio.get('/meal/suggest');
    final data = response.data['data'];
    if (data == null || data is! List) return [];

    // API returns list of Recipe objects with nested 'food' containing 'name'
    return data.map<String>((recipe) {
      if (recipe is Map<String, dynamic>) {
        // Try to get food name from nested food object
        final food = recipe['food'];
        if (food is Map<String, dynamic>) {
          return food['name']?.toString() ?? 'Món ăn';
        }
        // Fallback to recipe name if no food
        return recipe['name']?.toString() ?? 'Món ăn';
      }
      return 'Món ăn';
    }).toList();
  }
}

@LazySingleton(as: MealPlanRepository)
class MealPlanRepositoryImpl implements MealPlanRepository {
  final MealPlanRemoteDataSource _dataSource;
  MealPlanRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<MealPlan>>> getMealPlan(DateTime date) async {
    try {
      final result = await _dataSource.getMealPlan(date);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to load meal plan',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMealPlan(
    DateTime date,
    String mealType,
    String foodName,
    int? recipeId,
  ) async {
    try {
      await _dataSource.addMealPlan(date, mealType, foodName, recipeId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to add meal'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMealPlan(int id) async {
    try {
      await _dataSource.deleteMealPlan(id);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(e.response?.data['message'] ?? 'Failed to delete meal'),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSuggestions() async {
    try {
      final result = await _dataSource.getSuggestions();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to load suggestions',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
