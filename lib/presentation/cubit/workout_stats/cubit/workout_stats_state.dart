part of 'workout_stats_cubit.dart';

sealed class WorkoutStatsState extends Equatable {
  const WorkoutStatsState();

  @override
  List<Object> get props => [];
}

final class WorkoutStatsInitial extends WorkoutStatsState {}
