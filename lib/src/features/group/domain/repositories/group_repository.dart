import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group.dart';
import '../entities/group_detail.dart';

abstract class GroupRepository {
  Future<Either<Failure, List<Group>>> getGroups();
  Future<Either<Failure, GroupDetail>> getGroupDetail(int groupId);
  Future<Either<Failure, void>> createGroup(String name);
  Future<Either<Failure, void>> addMember(String username, int? groupId);
  Future<Either<Failure, void>> removeMember(int groupId, int userId);
}
