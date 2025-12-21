import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/group_repository.dart';

@lazySingleton
class RemoveMemberUseCase implements UseCase<void, RemoveMemberParams> {
  final GroupRepository repository;

  RemoveMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveMemberParams params) async {
    return await repository.removeMember(params.groupId, params.userId);
  }
}

class RemoveMemberParams extends Equatable {
  final int groupId;
  final int userId;

  const RemoveMemberParams({required this.groupId, required this.userId});

  @override
  List<Object> get props => [groupId, userId];
}
