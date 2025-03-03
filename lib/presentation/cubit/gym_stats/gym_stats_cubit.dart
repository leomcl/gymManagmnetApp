import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/usecases/gym_stats/get_current_gym_occupancy.dart';
import 'package:test/presentation/cubit/gym_stats/gym_stats_state.dart';

class GymStatsCubit extends Cubit<GymStatsState> {
  final GetCurrentGymOccupancy _getCurrentGymOccupancy;
  StreamSubscription? _occupancySubscription;

  GymStatsCubit(this._getCurrentGymOccupancy) : super(const GymStatsState());

  void startMonitoringOccupancy() {
    emit(state.copyWith(isLoading: true));
    
    _occupancySubscription?.cancel();
    _occupancySubscription = _getCurrentGymOccupancy().listen(
      (occupancy) {
        emit(state.copyWith(
          isLoading: false,
          occupancy: occupancy,
        ));
      },
      onError: (error) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Error loading occupancy: $error',
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _occupancySubscription?.cancel();
    return super.close();
  }
} 