import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class DeleteUserByAdminUseCase implements UseCase<void, int> {
  final AdminRepository _repository;

  DeleteUserByAdminUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(int params) {
    return _repository.deleteUser(params);
  }
}
