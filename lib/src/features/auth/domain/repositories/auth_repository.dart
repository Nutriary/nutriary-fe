import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> login(String email, String password);
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
    String username,
  );
}
