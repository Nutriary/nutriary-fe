import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/unit.dart';

abstract class UnitRepository {
  Future<Either<Failure, List<UnitEntity>>> getUnits();
  Future<Either<Failure, void>> createUnit(String name);
  Future<Either<Failure, void>> updateUnit(String oldName, String newName);
  Future<Either<Failure, void>> deleteUnit(String name);
}
