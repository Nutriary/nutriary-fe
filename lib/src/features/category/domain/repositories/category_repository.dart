import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<String>>> getCategories();
  Future<Either<Failure, void>> createCategory(String name);
  Future<Either<Failure, void>> updateCategory(String oldName, String newName);
  Future<Either<Failure, void>> deleteCategory(String name);
}
