import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/group_repository.dart';

@lazySingleton
class AddMemberUseCase extends UseCase<void, String> {
  final GroupRepository repository;

  AddMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.addMember(params);
  }
}
