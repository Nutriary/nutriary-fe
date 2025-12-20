import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/group_detail.dart';
import '../../domain/repositories/group_repository.dart';

@lazySingleton
class GetGroupDetailUseCase extends UseCase<GroupDetail, int> {
  final GroupRepository repository;

  GetGroupDetailUseCase(this.repository);

  @override
  Future<Either<Failure, GroupDetail>> call(int params) {
    return repository.getGroupDetail(params);
  }
}
