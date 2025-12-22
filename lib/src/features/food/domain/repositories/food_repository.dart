import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/food.dart';

abstract class FoodRepository {
  Future<Either<Failure, List<Food>>> getFoods();
  Future<Either<Failure, void>> createFood({
    required String name,
    required String category,
    required String unit,
    File? image,
  });
  Future<Either<Failure, void>> updateFood({
    required String name,
    String? newCategory,
    String? newUnit,
    File? image,
  });
  Future<Either<Failure, void>> deleteFood(String name);
}
