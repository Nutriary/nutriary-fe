import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/statistics_usecases.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

@injectable
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetConsumptionStatsUseCase getConsumptionStatsUseCase;
  final GetShoppingStatsUseCase getShoppingStatsUseCase;

  StatisticsBloc(this.getConsumptionStatsUseCase, this.getShoppingStatsUseCase)
    : super(const StatisticsState()) {
    on<LoadConsumptionStats>(_onLoadConsumption);
    on<LoadShoppingStats>(_onLoadShopping);
  }

  Future<void> _onLoadConsumption(
    LoadConsumptionStats event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    final result = await getConsumptionStatsUseCase(
      StatisticsParams(from: event.from, to: event.to),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stats) => emit(
        state.copyWith(
          status: StatisticsStatus.success,
          consumptionStats: stats,
        ),
      ),
    );
  }

  Future<void> _onLoadShopping(
    LoadShoppingStats event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    final result = await getShoppingStatsUseCase(
      StatisticsParams(from: event.from, to: event.to),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: StatisticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (stats) => emit(
        state.copyWith(status: StatisticsStatus.success, shoppingStats: stats),
      ),
    );
  }
}
