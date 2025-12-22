import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/unit_repository.dart';

@lazySingleton
class UpdateUnitUseCase extends UseCase<void, UpdateUnitParams> {
  final UnitRepository repository;

  UpdateUnitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUnitParams params) async {
    return await repository.updateUnit(params.oldName, params.newName);
  }
}

class UpdateUnitParams extends Equatable {
  final String oldName;
  final String newName;
  const UpdateUnitParams(this.oldName, this.newName);

  @override
  List<Object?> get props => [oldName, newName];
}
