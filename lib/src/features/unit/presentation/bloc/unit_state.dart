import 'package:equatable/equatable.dart';
import '../../domain/entities/unit.dart';

enum UnitStatus { initial, loading, success, failure }

class UnitState extends Equatable {
  final UnitStatus status;
  final List<UnitEntity> units;
  final String? errorMessage;
  final bool isLoadingAction;

  const UnitState({
    this.status = UnitStatus.initial,
    this.units = const [],
    this.errorMessage,
    this.isLoadingAction = false,
  });

  UnitState copyWith({
    UnitStatus? status,
    List<UnitEntity>? units,
    String? errorMessage,
    bool? isLoadingAction,
  }) {
    return UnitState(
      status: status ?? this.status,
      units: units ?? this.units,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
    );
  }

  @override
  List<Object?> get props => [status, units, errorMessage, isLoadingAction];
}
