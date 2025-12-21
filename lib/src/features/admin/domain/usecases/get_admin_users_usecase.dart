import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../user/domain/entities/user.dart';
import '../repositories/admin_repository.dart';

class GetAdminUsersParams {
  final int page;
  final int size;
  GetAdminUsersParams({this.page = 1, this.size = 20});
}

@lazySingleton
class GetAdminUsersUseCase implements UseCase<List<User>, GetAdminUsersParams> {
  final AdminRepository repository;

  GetAdminUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<User>>> call(GetAdminUsersParams params) async {
    return await repository.getUsers(page: params.page, size: params.size);
  }
}
