import 'package:equatable/equatable.dart';

class WorkoutSelectionState extends Equatable {
  final Map<String, bool> selectedWorkouts;

  const WorkoutSelectionState({
    required this.selectedWorkouts,
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
    );
  }

  WorkoutSelectionState copyWith({
    Map<String, bool>? selectedWorkouts,
  }) {
    return WorkoutSelectionState(
      selectedWorkouts: selectedWorkouts ?? this.selectedWorkouts,
    );
  }

  @override
  List<Object?> get props => [selectedWorkouts];
}
