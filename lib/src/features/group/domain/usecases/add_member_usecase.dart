import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/group_repository.dart';

class AddMemberParams extends Equatable {
  final String username;
  final int? groupId;

  const AddMemberParams({required this.username, this.groupId});

  @override
  List<Object?> get props => [username, groupId];
}

@lazySingleton
class AddMemberUseCase extends UseCase<void, AddMemberParams> {
  final GroupRepository repository;

  AddMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddMemberParams params) {
    return repository.addMember(params.username, params.groupId);
  }
}
