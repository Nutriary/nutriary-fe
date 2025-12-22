import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/food_repository.dart';

@lazySingleton
class CreateFoodUseCase implements UseCase<void, CreateFoodParams> {
  final FoodRepository _repository;

  CreateFoodUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CreateFoodParams params) {
    return _repository.createFood(
      name: params.name,
      category: params.category,
      unit: params.unit,
      image: params.image,
    );
  }
}

class CreateFoodParams extends Equatable {
  final String name;
  final String category;
  final String unit;
  final File? image;

  const CreateFoodParams({
    required this.name,
    required this.category,
    required this.unit,
    this.image,
  });

  @override
  List<Object?> get props => [name, category, unit, image];
}
