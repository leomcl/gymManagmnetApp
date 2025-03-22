part of 'optimal_workout_cubit.dart';

abstract class OptimalWorkoutState extends Equatable {
  const OptimalWorkoutState();

  @override
  List<Object?> get props => [];
}

class OptimalWorkoutInitial extends OptimalWorkoutState {}

class OptimalWorkoutLoading extends OptimalWorkoutState {}

class OptimalWorkoutLoaded extends OptimalWorkoutState {
  final Map<int, List<int>> optimalTimes;
  final String formattedResult;

  const OptimalWorkoutLoaded({
    required this.optimalTimes,
    required this.formattedResult,
  });

  @override
  List<Object?> get props => [optimalTimes, formattedResult];
}

class OptimalWorkoutError extends OptimalWorkoutState {
  final String message;

  const OptimalWorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}
