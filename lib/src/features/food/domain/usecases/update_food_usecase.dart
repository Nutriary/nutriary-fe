import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/food_repository.dart';

@lazySingleton
class UpdateFoodUseCase implements UseCase<void, UpdateFoodParams> {
  final FoodRepository _repository;

  UpdateFoodUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateFoodParams params) {
    return _repository.updateFood(
      name: params.name,
      newCategory: params.newCategory,
      newUnit: params.newUnit,
      image: params.image,
    );
  }
}

class UpdateFoodParams extends Equatable {
  final String name;
  final String? newCategory;
  final String? newUnit;
  final File? image;

  const UpdateFoodParams({
    required this.name,
    this.newCategory,
    this.newUnit,
    this.image,
  });

  @override
  List<Object?> get props => [name, newCategory, newUnit, image];
}
