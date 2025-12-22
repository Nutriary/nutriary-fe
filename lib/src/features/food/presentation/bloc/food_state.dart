import 'package:equatable/equatable.dart';
import '../../domain/entities/food.dart';

enum FoodStatus { initial, loading, success, failure }

class FoodState extends Equatable {
  final FoodStatus status;
  final List<Food> foods;
  final String? errorMessage;
  final bool isLoadingAction;

  const FoodState({
    this.status = FoodStatus.initial,
    this.foods = const [],
    this.errorMessage,
    this.isLoadingAction = false,
  });

  FoodState copyWith({
    FoodStatus? status,
    List<Food>? foods,
    String? errorMessage,
    bool? isLoadingAction,
  }) {
    return FoodState(
      status: status ?? this.status,
      foods: foods ?? this.foods,
      errorMessage: errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
    );
  }

  @override
  List<Object?> get props => [status, foods, errorMessage, isLoadingAction];
}
