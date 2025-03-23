part of 'workout_stats_cubit.dart';

enum WorkoutStatsStatus { initial, loading, success, failure }

class WorkoutStatsState extends Equatable {
  final WorkoutStatsStatus status;
  final List<Workout> workouts;
  final String? error;

  const WorkoutStatsState({
    this.status = WorkoutStatsStatus.initial,
    this.workouts = const [],
    this.error,
  });

  WorkoutStatsState copyWith({
    WorkoutStatsStatus? status,
    List<Workout>? workouts,
    String? error,
  }) {
    return WorkoutStatsState(
      status: status ?? this.status,
      workouts: workouts ?? this.workouts,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, workouts, error];
}

final class WorkoutStatsInitial extends WorkoutStatsState {}
