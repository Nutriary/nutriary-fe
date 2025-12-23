import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getAllRecipes();
  Future<void> createRecipe(
    String name,
    String content, {
    required List<Map<String, String>> ingredients,
    bool isPublic = true,
    int? groupId,
  });
  Future<void> updateRecipe(int id, {String? name, String? content});
  Future<void> deleteRecipe(int id);
  Future<List<RecipeModel>> getRecipesByFood(int foodId);
}

@LazySingleton(as: RecipeRemoteDataSource)
class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final Dio _dio;
  RecipeRemoteDataSourceImpl(this._dio);

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    final response = await _dio.get('/recipe/all');
    final responseData = response.data['data'];
    // Handle pagination or loose structure
    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      return (responseData['data'] as List)
          .map((e) => RecipeModel.fromJson(e))
          .toList();
    }
    final list = (responseData as List?) ?? [];
    return list.map((e) => RecipeModel.fromJson(e)).toList();
  }

  @override
  Future<void> createRecipe(
    String name,
    String content, {
    required List<Map<String, String>> ingredients,
    bool isPublic = true,
    int? groupId,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'htmlContent': content,
      'isPublic': isPublic,
      'ingredients': ingredients,
    };
    if (groupId != null) {
      body['groupId'] = groupId;
    }
    await _dio.post('/recipe', data: body);
  }

  @override
  Future<void> updateRecipe(int id, {String? name, String? content}) async {
    final data = <String, dynamic>{'recipeId': id};
    if (name != null) data['newName'] = name;
    if (content != null) data['newHtmlContent'] = content;
    await _dio.put('/recipe', data: data);
  }

  @override
  Future<void> deleteRecipe(int id) async {
    await _dio.delete('/recipe', data: {'recipeId': id});
  }

  @override
  Future<List<RecipeModel>> getRecipesByFood(int foodId) async {
    final response = await _dio.get(
      '/recipe',
      queryParameters: {'foodId': foodId},
    );
    final data = response.data['data'] as List?;
    return data?.map((e) => RecipeModel.fromJson(e)).toList() ?? [];
  }
}

@LazySingleton(as: RecipeRepository)
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource _dataSource;
  RecipeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Recipe>>> getAllRecipes() async {
    try {
      final result = await _dataSource.getAllRecipes();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to load recipes',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createRecipe(
    String name,
    String content, {
    required List<Map<String, String>> ingredients,
    bool isPublic = true,
    int? groupId,
  }) async {
    try {
      await _dataSource.createRecipe(
        name,
        content,
        ingredients: ingredients,
        isPublic: isPublic,
        groupId: groupId,
      );
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to create recipe',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRecipe(
    int id, {
    String? name,
    String? content,
  }) async {
    try {
      await _dataSource.updateRecipe(id, name: name, content: content);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to update recipe',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecipe(int id) async {
    try {
      await _dataSource.deleteRecipe(id);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to delete recipe',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipesByFood(int foodId) async {
    try {
      final result = await _dataSource.getRecipesByFood(foodId);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(
          ServerFailure(
            e.response?.data['message'] ?? 'Failed to load recipes',
          ),
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
