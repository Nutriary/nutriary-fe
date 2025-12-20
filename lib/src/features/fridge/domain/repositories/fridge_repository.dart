import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/fridge_item.dart';

abstract class FridgeRepository {
  Future<Either<Failure, List<FridgeItem>>> getFridgeItems(int? groupId);
  Future<Either<Failure, void>> addFridgeItem({
    required String foodName,
    required String quantity,
    DateTime? useWithin,
    String? categoryName,
    int? groupId,
  });
  Future<Either<Failure, void>> updateFridgeItem({
    required String foodName,
    String? quantity,
    DateTime? useWithin,
    int? groupId,
  });
  Future<Either<Failure, void>> removeFridgeItem(String foodName, int? groupId);
}
