import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/user_repository.dart';

@lazySingleton
class DeleteAccountUseCase implements UseCase<void, NoParams> {
  final UserRepository _repository;

  DeleteAccountUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.deleteAccount();
  }
}
