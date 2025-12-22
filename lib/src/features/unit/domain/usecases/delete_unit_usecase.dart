import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/unit_repository.dart';

@lazySingleton
class DeleteUnitUseCase extends UseCase<void, String> {
  final UnitRepository repository;

  DeleteUnitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteUnit(params);
  }
}
