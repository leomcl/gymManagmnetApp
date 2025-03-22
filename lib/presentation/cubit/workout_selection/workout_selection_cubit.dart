import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_state.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';

class WorkoutSelectionCubit extends Cubit<WorkoutSelectionState> {
  WorkoutSelectionCubit() : super(WorkoutSelectionState.initial());

  void toggleWorkout(String workout) {
    final updatedWorkouts = Map<String, bool>.from(state.selectedWorkouts);
    updatedWorkouts[workout] = !updatedWorkouts[workout]!;

    emit(state.copyWith(selectedWorkouts: updatedWorkouts));
  }

  // Method to get currently selected workouts
  Map<String, bool> getSelectedWorkouts() {
    return state.selectedWorkouts;
  }

  // Method to sync with the main WorkoutCubit if needed
  void syncWithWorkoutState(WorkoutState workoutState) {
    if (workoutState.selectedWorkouts.isNotEmpty) {
      emit(state.copyWith(
          selectedWorkouts:
              Map<String, bool>.from(workoutState.selectedWorkouts)));
    }
  }
}
