import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/food_repository.dart';

@lazySingleton
class DeleteFoodUseCase implements UseCase<void, String> {
  final FoodRepository _repository;

  DeleteFoodUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return _repository.deleteFood(params);
  }
}
