import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/group_detail.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_data_source.dart';

@LazySingleton(as: GroupRepository)
class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remoteDataSource;

  GroupRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Group>>> getGroups() async {
    try {
      final groups = await remoteDataSource.getGroups();
      return Right(groups);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to fetch groups'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GroupDetail>> getGroupDetail(int groupId) async {
    try {
      final group = await remoteDataSource.getGroupDetail(groupId);
      return Right(group);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          e.response?.data['message'] ?? 'Failed to fetch group detail',
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createGroup(String name) async {
    try {
      await remoteDataSource.createGroup(name);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to create group'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMember(String username) async {
    try {
      await remoteDataSource.addMember(username);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Failed to add member'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
