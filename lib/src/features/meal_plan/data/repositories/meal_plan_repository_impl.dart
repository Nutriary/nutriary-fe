import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../models/meal_plan_model.dart';

abstract class MealPlanRemoteDataSource {
  Future<List<MealPlanModel>> getMealPlan(DateTime date, int? groupId);
  Future<void> addMealPlan(
    DateTime date,
    String mealType,
    String foodName,
    int? recipeId,
    int? groupId,
  );
  Future<void> deleteMealPlan(int id);
  Future<List<String>> getSuggestions(int? groupId);
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
  Future<List<MealPlanModel>> getMealPlan(DateTime date, int? groupId) async {
    final formattedDate = date.toIso8601String().split('T')[0];
    final response = await _dio.get(
      '/meal',
      queryParameters: {
        'date': formattedDate,
        if (groupId != null) 'groupId': groupId,
      },
    );
    final responseData = response.data['data'];
    List<dynamic> list = [];
    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      list = responseData['data'] as List<dynamic>;
    } else {
      list = (responseData as List?) ?? [];
    }

    return list.map((item) {
      final apiType = item['name'] as String? ?? '';
      final uiType = _apiToMealType[apiType] ?? apiType;
      final newItem = Map<String, dynamic>.from(item);
      newItem['name'] = uiType;
      return MealPlanModel.fromJson(newItem);
    }).toList();
  }

  @override
  Future<void> addMealPlan(
    DateTime date,
    String mealType,
    String foodName,
    int? recipeId,
    int? groupId,
  ) async {
    final apiType = _mealTypeToApi[mealType] ?? mealType;
    await _dio.post(
      '/meal',
      data: {
        'name': apiType,
        'foodName': foodName,
        'timestamp': date.toIso8601String(),
        if (recipeId != null) 'recipeId': recipeId,
        if (groupId != null) 'groupId': groupId,
      },
    );
  }

  @override
  Future<void> deleteMealPlan(int id) async {
    await _dio.delete('/meal', data: {'planId': id});
  }

  @override
  Future<List<String>> getSuggestions(int? groupId) async {
    final response = await _dio.get(
      '/meal/suggest',
      queryParameters: {if (groupId != null) 'groupId': groupId},
    );
    final data = response.data['data'];
    if (data == null || data is! List) return [];

    return data.map<String>((recipe) {
      if (recipe is Map<String, dynamic>) {
        final food = recipe['food'];
        if (food is Map<String, dynamic>) {
          return food['name']?.toString() ?? 'Món ăn';
        }
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
  Future<Either<Failure, List<MealPlan>>> getMealPlan(
    DateTime date,
    int? groupId,
  ) async {
    try {
      final result = await _dataSource.getMealPlan(date, groupId);
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
    int? groupId,
  ) async {
    try {
      await _dataSource.addMealPlan(
        date,
        mealType,
        foodName,
        recipeId,
        groupId,
      );
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
  Future<Either<Failure, List<String>>> getSuggestions(int? groupId) async {
    try {
      final result = await _dataSource.getSuggestions(groupId);
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
