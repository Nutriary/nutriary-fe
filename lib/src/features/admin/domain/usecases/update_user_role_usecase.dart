import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

class UpdateUserRoleParams {
  final int userId;
  final String role;
  UpdateUserRoleParams({required this.userId, required this.role});
}

@lazySingleton
class UpdateUserRoleUseCase implements UseCase<void, UpdateUserRoleParams> {
  final AdminRepository repository;

  UpdateUserRoleUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserRoleParams params) async {
    return await repository.updateUserRole(params.userId, params.role);
  }
}
