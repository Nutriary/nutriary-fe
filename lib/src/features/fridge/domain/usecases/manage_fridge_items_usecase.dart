import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/fridge_repository.dart';

@lazySingleton
class AddFridgeItemUseCase extends UseCase<void, AddFridgeItemParams> {
  final FridgeRepository repository;
  AddFridgeItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddFridgeItemParams params) {
    return repository.addFridgeItem(
      foodName: params.foodName,
      quantity: params.quantity,
      useWithin: params.useWithin,
      categoryName: params.categoryName,
      groupId: params.groupId,
    );
  }
}

class AddFridgeItemParams extends Equatable {
  final String foodName;
  final String quantity;
  final DateTime? useWithin;
  final String? categoryName;
  final int? groupId;

  const AddFridgeItemParams({
    required this.foodName,
    required this.quantity,
    this.useWithin,
    this.categoryName,
    this.groupId,
  });

  @override
  List<Object?> get props => [
    foodName,
    quantity,
    useWithin,
    categoryName,
    groupId,
  ];
}

@lazySingleton
class UpdateFridgeItemUseCase extends UseCase<void, UpdateFridgeItemParams> {
  final FridgeRepository repository;
  UpdateFridgeItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateFridgeItemParams params) {
    return repository.updateFridgeItem(
      foodName: params.foodName,
      quantity: params.quantity,
      useWithin: params.useWithin,
      groupId: params.groupId,
    );
  }
}

class UpdateFridgeItemParams extends Equatable {
  final String foodName;
  final String? quantity;
  final DateTime? useWithin;
  final int? groupId;

  const UpdateFridgeItemParams({
    required this.foodName,
    this.quantity,
    this.useWithin,
    this.groupId,
  });

  @override
  List<Object?> get props => [foodName, quantity, useWithin, groupId];
}

@lazySingleton
class RemoveFridgeItemUseCase extends UseCase<void, RemoveFridgeItemParams> {
  final FridgeRepository repository;
  RemoveFridgeItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFridgeItemParams params) {
    return repository.removeFridgeItem(params.foodName, params.groupId);
  }
}

class RemoveFridgeItemParams extends Equatable {
  final String foodName;
  final int? groupId;
  const RemoveFridgeItemParams(this.foodName, this.groupId);
  @override
  List<Object?> get props => [foodName, groupId];
}

@lazySingleton
class ConsumeFridgeItemUseCase extends UseCase<void, ConsumeFridgeItemParams> {
  final FridgeRepository repository;
  ConsumeFridgeItemUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ConsumeFridgeItemParams params) {
    return repository.consumeFridgeItem(
      foodName: params.foodName,
      quantity: params.quantity,
      groupId: params.groupId,
    );
  }
}

class ConsumeFridgeItemParams extends Equatable {
  final String foodName;
  final double quantity;
  final int? groupId;
  const ConsumeFridgeItemParams({
    required this.foodName,
    required this.quantity,
    this.groupId,
  });
  @override
  List<Object?> get props => [foodName, quantity, groupId];
}
