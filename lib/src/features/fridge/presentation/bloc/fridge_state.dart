import 'package:equatable/equatable.dart';
import '../../domain/entities/fridge_item.dart';

enum FridgeStatus { initial, loading, success, failure }

enum FridgeFilter { all, expiring }

class FridgeState extends Equatable {
  final FridgeStatus status;
  final List<FridgeItem> items;
  final List<String> categories;
  final FridgeFilter filter;
  final String? errorMessage;
  final bool isLoadingAction;

  const FridgeState({
    this.status = FridgeStatus.initial,
    this.items = const [],
    this.categories = const [],
    this.filter = FridgeFilter.all,
    this.errorMessage,
    this.isLoadingAction = false,
  });

  // Getter for filtered items
  List<FridgeItem> get filteredItems {
    if (filter == FridgeFilter.all) return items;
    return items.where((item) {
      if (item.useWithin == null) return false;
      final daysLeft = item.useWithin!.difference(DateTime.now()).inDays;
      return daysLeft <= 3;
    }).toList();
  }

  FridgeState copyWith({
    FridgeStatus? status,
    List<FridgeItem>? items,
    List<String>? categories,
    FridgeFilter? filter,
    String? errorMessage,
    bool? isLoadingAction,
  }) {
    return FridgeState(
      status: status ?? this.status,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    categories,
    filter,
    errorMessage,
    isLoadingAction,
  ];
}
