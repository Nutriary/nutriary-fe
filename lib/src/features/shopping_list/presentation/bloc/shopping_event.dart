import 'package:equatable/equatable.dart';
import 'package:nutriary_fe/src/features/shopping_list/domain/entities/shopping_task.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();
  @override
  List<Object?> get props => [];
}

class LoadShoppingTasks extends ShoppingEvent {
  final int listId;
  const LoadShoppingTasks(this.listId);
  @override
  List<Object?> get props => [listId];
}

class CreateList extends ShoppingEvent {
  final String name;
  final String? note;
  final int? groupId;
  const CreateList(this.name, this.note, this.groupId);
  @override
  List<Object?> get props => [name, note, groupId];
}

class UpdateList extends ShoppingEvent {
  final int listId;
  final String name;
  final String? note;
  const UpdateList(this.listId, this.name, this.note);
  @override
  List<Object?> get props => [listId, name, note];
}

class DeleteList extends ShoppingEvent {
  final int listId;
  const DeleteList(this.listId);
  @override
  List<Object?> get props => [listId];
}

class AddShoppingTask extends ShoppingEvent {
  final int listId;
  final String foodName;
  final String quantity;
  const AddShoppingTask(this.listId, this.foodName, this.quantity);
  @override
  List<Object?> get props => [listId, foodName, quantity];
}

class UpdateShoppingTask extends ShoppingEvent {
  final int taskId;
  final int listId; // needed to refresh
  final bool? isBought;
  final String? quantity;
  final int? assigneeUserId;
  const UpdateShoppingTask({
    required this.taskId,
    required this.listId,
    this.isBought,
    this.quantity,
    this.assigneeUserId,
  });
  @override
  List<Object?> get props => [
    taskId,
    listId,
    isBought,
    quantity,
    assigneeUserId,
  ];
}

class DeleteShoppingTask extends ShoppingEvent {
  final int taskId;
  final int listId;
  const DeleteShoppingTask(this.taskId, this.listId);
  @override
  List<Object?> get props => [taskId, listId];
}

class ReorderShoppingTasks extends ShoppingEvent {
  final List<ShoppingTask> tasks; // New order
  final int listId;
  const ReorderShoppingTasks(this.tasks, this.listId);
  @override
  List<Object?> get props => [tasks, listId];
}

class AssignShoppingTask extends ShoppingEvent {
  final int taskId;
  final int listId;
  final int assigneeUserId;
  const AssignShoppingTask({
    required this.taskId,
    required this.listId,
    required this.assigneeUserId,
  });
  @override
  List<Object?> get props => [taskId, listId, assigneeUserId];
}
