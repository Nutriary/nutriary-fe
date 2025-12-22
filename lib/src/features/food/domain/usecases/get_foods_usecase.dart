import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/food.dart';
import '../repositories/food_repository.dart';

@lazySingleton
class GetFoodsUseCase implements UseCase<List<Food>, NoParams> {
  final FoodRepository _repository;

  GetFoodsUseCase(this._repository);

  @override
  Future<Either<Failure, List<Food>>> call(NoParams params) {
    return _repository.getFoods();
  }
}
