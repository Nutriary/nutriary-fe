import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<String>>> getCategories();
}
