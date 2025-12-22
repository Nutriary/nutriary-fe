import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/unit.dart';
import '../repositories/unit_repository.dart';

@lazySingleton
class GetUnitsUseCase extends UseCase<List<UnitEntity>, NoParams> {
  final UnitRepository repository;

  GetUnitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<UnitEntity>>> call(NoParams params) async {
    return await repository.getUnits();
  }
}
