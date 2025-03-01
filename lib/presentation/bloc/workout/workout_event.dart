import 'package:equatable/equatable.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class ToggleWorkoutEvent extends WorkoutEvent {
  final String workout;

  const ToggleWorkoutEvent(this.workout);

  @override
  List<Object?> get props => [workout];
}

class SaveWorkoutEvent extends WorkoutEvent {
  final String userId;

  const SaveWorkoutEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GenerateExitCodeEvent extends WorkoutEvent {
  final String userId;

  const GenerateExitCodeEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class GenerateCodeEvent extends WorkoutEvent {
  final String userId;
  final bool isEntry;

  GenerateCodeEvent({
    required this.userId,
    required this.isEntry,
  });

  @override
  List<Object> get props => [userId, isEntry];
} 