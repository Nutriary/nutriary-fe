import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class UpdateCategoryUseCase extends UseCase<void, UpdateCategoryParams> {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(params.oldName, params.newName);
  }
}

class UpdateCategoryParams extends Equatable {
  final String oldName;
  final String newName;
  const UpdateCategoryParams(this.oldName, this.newName);

  @override
  List<Object?> get props => [oldName, newName];
}
