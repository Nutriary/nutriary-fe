import 'package:equatable/equatable.dart';
import '../../domain/entities/meal_plan.dart';

enum MealPlanStatus { initial, loading, success, failure }

class MealPlanState extends Equatable {
  final MealPlanStatus status;
  final List<MealPlan> mealPlans;
  final List<String> suggestions;
  final String? errorMessage;
  final bool isLoadingAction;
  final DateTime? selectedDate;

  const MealPlanState({
    this.status = MealPlanStatus.initial,
    this.mealPlans = const [],
    this.suggestions = const [],
    this.errorMessage,
    this.isLoadingAction = false,
    this.selectedDate,
  });

  MealPlanState copyWith({
    MealPlanStatus? status,
    List<MealPlan>? mealPlans,
    List<String>? suggestions,
    String? errorMessage,
    bool? isLoadingAction,
    DateTime? selectedDate,
  }) {
    return MealPlanState(
      status: status ?? this.status,
      mealPlans: mealPlans ?? this.mealPlans,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [
    status,
    mealPlans,
    suggestions,
    errorMessage,
    isLoadingAction,
    selectedDate,
  ];
}
