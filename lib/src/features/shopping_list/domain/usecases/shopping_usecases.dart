import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shopping_task.dart';
import '../repositories/shopping_repository.dart';

@lazySingleton
class GetShoppingTasksUseCase extends UseCase<List<ShoppingTask>, int> {
  final ShoppingRepository repository;
  GetShoppingTasksUseCase(this.repository);
  @override
  Future<Either<Failure, List<ShoppingTask>>> call(int listId) =>
      repository.getTasks(listId);
}

@lazySingleton
class CreateShoppingListUseCase
    extends UseCase<void, CreateShoppingListParams> {
  final ShoppingRepository repository;
  CreateShoppingListUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(CreateShoppingListParams params) =>
      repository.createShoppingList(params.name, params.note, params.groupId);
}

class CreateShoppingListParams extends Equatable {
  final String name;
  final String? note;
  final int? groupId;
  const CreateShoppingListParams(this.name, this.note, this.groupId);
  @override
  List<Object?> get props => [name, note, groupId];
}

@lazySingleton
class AddShoppingTaskUseCase extends UseCase<void, AddShoppingTaskParams> {
  final ShoppingRepository repository;
  AddShoppingTaskUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(AddShoppingTaskParams params) =>
      repository.addTask(
        listId: params.listId,
        foodName: params.foodName,
        quantity: params.quantity,
      );
}

class AddShoppingTaskParams extends Equatable {
  final int listId;
  final String foodName;
  final String quantity;
  const AddShoppingTaskParams(this.listId, this.foodName, this.quantity);
  @override
  List<Object?> get props => [listId, foodName, quantity];
}

@lazySingleton
class UpdateShoppingTaskUseCase
    extends UseCase<void, UpdateShoppingTaskParams> {
  final ShoppingRepository repository;
  UpdateShoppingTaskUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(UpdateShoppingTaskParams params) =>
      repository.updateTask(
        taskId: params.taskId,
        isBought: params.isBought,
        quantity: params.quantity,
      );
}

class UpdateShoppingTaskParams extends Equatable {
  final int taskId;
  final bool? isBought;
  final String? quantity;
  const UpdateShoppingTaskParams({
    required this.taskId,
    this.isBought,
    this.quantity,
  });
  @override
  List<Object?> get props => [taskId, isBought, quantity];
}

@lazySingleton
class DeleteShoppingTaskUseCase extends UseCase<void, int> {
  final ShoppingRepository repository;
  DeleteShoppingTaskUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(int taskId) =>
      repository.deleteTask(taskId);
}

@lazySingleton
class ReorderShoppingTasksUseCase extends UseCase<void, List<ShoppingTask>> {
  final ShoppingRepository repository;
  ReorderShoppingTasksUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(List<ShoppingTask> tasks) =>
      repository.reorderTasks(tasks);
}
