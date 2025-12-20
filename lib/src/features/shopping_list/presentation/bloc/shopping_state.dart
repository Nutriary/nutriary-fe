import 'package:equatable/equatable.dart';
import 'package:nutriary_fe/src/features/shopping_list/domain/entities/shopping_task.dart';

enum ShoppingStatus { initial, loading, success, failure }

class ShoppingState extends Equatable {
  final ShoppingStatus status;
  final List<ShoppingTask> tasks;
  final String? errorMessage;
  final bool isLoadingAction;
  final int? currentListId;

  const ShoppingState({
    this.status = ShoppingStatus.initial,
    this.tasks = const [],
    this.errorMessage,
    this.isLoadingAction = false,
    this.currentListId,
  });

  ShoppingState copyWith({
    ShoppingStatus? status,
    List<ShoppingTask>? tasks,
    String? errorMessage,
    bool? isLoadingAction,
    int? currentListId,
  }) {
    return ShoppingState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
      currentListId: currentListId ?? this.currentListId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    tasks,
    errorMessage,
    isLoadingAction,
    currentListId,
  ];
}
