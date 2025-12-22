import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/unit_repository.dart';

@lazySingleton
class CreateUnitUseCase extends UseCase<void, String> {
  final UnitRepository repository;

  CreateUnitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.createUnit(params);
  }
}
