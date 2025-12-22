import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/category_repository.dart';

@lazySingleton
class CreateCategoryUseCase extends UseCase<void, String> {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.createCategory(params);
  }
}
