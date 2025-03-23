import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:test/domain/entities/workout.dart';

part 'workout_stats_state.dart';

class WorkoutStatsCubit extends Cubit<WorkoutStatsState> {
  final WorkoutRepository _workoutRepository;
  final GetCurrentUser _getCurrentUser;

  WorkoutStatsCubit({
    required WorkoutRepository workoutRepository,
    required GetCurrentUser getCurrentUser,
  })  : _workoutRepository = workoutRepository,
        _getCurrentUser = getCurrentUser,
        super(const WorkoutStatsState());

  Future<void> loadWorkoutHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      emit(state.copyWith(status: WorkoutStatsStatus.loading));

      // Get current user ID
      final currentUser = await _getCurrentUser();
      final userId = currentUser?.uid ?? '';

      final workouts = await _workoutRepository.getWorkoutHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      emit(state.copyWith(
        status: WorkoutStatsStatus.success,
        workouts: workouts,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: WorkoutStatsStatus.failure,
        error: error.toString(),
      ));
    }
  }
}
