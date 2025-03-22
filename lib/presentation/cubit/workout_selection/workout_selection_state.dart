import 'package:equatable/equatable.dart';
import 'package:test/domain/entities/gym_class.dart';

enum WorkoutMode { solo, class_ }

class WorkoutSelectionState extends Equatable {
  final Map<String, bool> selectedWorkouts;
  final WorkoutMode workoutMode;
  final List<GymClass> todayClasses;
  final GymClass? selectedClass;

  const WorkoutSelectionState({
    required this.selectedWorkouts,
    this.workoutMode = WorkoutMode.solo,
    this.todayClasses = const [],
    this.selectedClass,
  });

  factory WorkoutSelectionState.initial() {
    return const WorkoutSelectionState(
      selectedWorkouts: {
        'Cardio': false,
        'Legs': false,
        'Chest': false,
        'Arms': false,
        'Full Body': false,
      },
      workoutMode: WorkoutMode.solo,
      todayClasses: [],
      selectedClass: null,
    );
  }

  WorkoutSelectionState copyWith({
    Map<String, bool>? selectedWorkouts,
    WorkoutMode? workoutMode,
    List<GymClass>? todayClasses,
    GymClass? selectedClass,
    bool clearSelectedClass = false,
  }) {
    return WorkoutSelectionState(
      selectedWorkouts: selectedWorkouts ?? this.selectedWorkouts,
      workoutMode: workoutMode ?? this.workoutMode,
      todayClasses: todayClasses ?? this.todayClasses,
      selectedClass:
          clearSelectedClass ? null : (selectedClass ?? this.selectedClass),
    );
  }

  @override
  List<Object?> get props =>
      [selectedWorkouts, workoutMode, todayClasses, selectedClass];
}
