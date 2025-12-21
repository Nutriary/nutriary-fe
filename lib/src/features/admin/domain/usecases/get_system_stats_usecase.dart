import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/admin_repository.dart';
import '../entities/system_stats.dart';

@lazySingleton
class GetSystemStatsUseCase implements UseCase<SystemStats, NoParams> {
  final AdminRepository repository;

  GetSystemStatsUseCase(this.repository);

  @override
  Future<Either<Failure, SystemStats>> call(NoParams params) async {
    return await repository.getSystemStats();
  }
}
