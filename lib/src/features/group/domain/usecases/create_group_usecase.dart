import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/group_repository.dart';

@lazySingleton
class CreateGroupUseCase extends UseCase<void, String> {
  final GroupRepository repository;
  CreateGroupUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String name) =>
      repository.createGroup(name);
}
