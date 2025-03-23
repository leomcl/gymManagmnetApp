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
  final List<String> preferredWorkoutTypes;
  final List<int> preferredWorkoutDays;

  const OptimalWorkoutLoaded({
    required this.optimalTimes,
    required this.formattedResult,
    required this.preferredWorkoutTypes,
    required this.preferredWorkoutDays,
  });

  @override
  List<Object?> get props => [
        optimalTimes,
        formattedResult,
        preferredWorkoutTypes,
        preferredWorkoutDays
      ];
}

class OptimalWorkoutError extends OptimalWorkoutState {
  final String message;

  const OptimalWorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}
