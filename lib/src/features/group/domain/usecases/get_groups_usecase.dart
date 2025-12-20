import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';

@lazySingleton
class GetGroupsUseCase extends UseCase<List<Group>, NoParams> {
  final GroupRepository repository;

  GetGroupsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Group>>> call(NoParams params) {
    return repository.getGroups();
  }
}
