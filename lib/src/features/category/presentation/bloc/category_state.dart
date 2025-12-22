import 'package:equatable/equatable.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryEntity extends Equatable {
  final String name;
  const CategoryEntity({required this.name});
  @override
  List<Object?> get props => [name];
}

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategoryEntity> categories;
  final String? errorMessage;
  final bool isLoadingAction;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.isLoadingAction = false,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
    bool? isLoadingAction,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    errorMessage,
    isLoadingAction,
  ];
}
