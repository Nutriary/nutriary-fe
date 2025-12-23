import 'package:equatable/equatable.dart';
import '../../domain/entities/fridge_item.dart';

enum FridgeStatus { initial, loading, success, failure }

enum FridgeFilter { all, expiring }

class FridgeState extends Equatable {
  final FridgeStatus status;
  final List<FridgeItem> items;
  final List<String> categories;
  final FridgeFilter filter;
  final String searchQuery;
  final String? errorMessage;
  final bool isLoadingAction;

  const FridgeState({
    this.status = FridgeStatus.initial,
    this.items = const [],
    this.categories = const [],
    this.filter = FridgeFilter.all,
    this.errorMessage,
    this.isLoadingAction = false,
    this.searchQuery = '',
  });

  // Getter for filtered items
  List<FridgeItem> get filteredItems {
    var result = items;

    // 1. Search filter
    if (searchQuery.isNotEmpty) {
      result = result
          .where(
            (item) =>
                item.foodName.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    // 2. Status filter
    if (filter == FridgeFilter.all) return result;
    return result.where((item) {
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
    String? searchQuery,
  }) {
    return FridgeState(
      status: status ?? this.status,
      items: items ?? this.items,
      categories: categories ?? this.categories,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
      searchQuery: searchQuery ?? this.searchQuery,
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
    searchQuery,
  ];
}
