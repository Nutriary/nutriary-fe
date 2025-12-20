import 'package:dartz/dartz.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shopping_list.dart';
import '../entities/shopping_task.dart';

abstract class ShoppingRepository {
  // Lists
  Future<Either<Failure, List<ShoppingListEntity>>> getShoppingLists(
    int? groupId,
  );
  Future<Either<Failure, void>> createShoppingList(
    String name,
    String? note,
    int? groupId,
  );

  // Tasks
  Future<Either<Failure, List<ShoppingTask>>> getTasks(int listId);
  Future<Either<Failure, void>> addTask({
    required int listId,
    required String foodName,
    required String quantity,
  });
  Future<Either<Failure, void>> updateTask({
    required int taskId,
    bool? isBought,
    String? quantity,
  });
  Future<Either<Failure, void>> deleteTask(int taskId);
  Future<Either<Failure, void>> reorderTasks(List<ShoppingTask> tasks);
}
