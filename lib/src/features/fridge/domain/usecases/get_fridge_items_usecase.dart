import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/fridge_item.dart';
import '../../domain/repositories/fridge_repository.dart';

@lazySingleton
class GetFridgeItemsUseCase extends UseCase<List<FridgeItem>, int?> {
  final FridgeRepository repository;

  GetFridgeItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FridgeItem>>> call(int? params) {
    return repository.getFridgeItems(params);
  }
}
