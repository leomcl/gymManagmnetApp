import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_state.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_date.dart';
import 'package:test/domain/entities/gym_class.dart';

class WorkoutSelectionCubit extends Cubit<WorkoutSelectionState> {
  final GetClassesByDate? getClassesByDate;

  WorkoutSelectionCubit({this.getClassesByDate})
      : super(WorkoutSelectionState.initial());

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

  // Set workout mode (solo or class)
  void setWorkoutMode(WorkoutMode mode) async {
    if (mode == WorkoutMode.class_) {
      await fetchTodayClasses();
    }

    emit(state.copyWith(
      workoutMode: mode,
      clearSelectedClass: true,
      selectedWorkouts: WorkoutSelectionState.initial().selectedWorkouts,
    ));
  }

  // Fetch classes for today
  Future<void> fetchTodayClasses() async {
    if (getClassesByDate == null) return;

    try {
      final today = DateTime.now();
      final classes = await getClassesByDate!(today);
      emit(state.copyWith(todayClasses: classes));
    } catch (e) {
      // Handle error
      emit(state.copyWith(todayClasses: []));
    }
  }

  // Select a class
  void selectClass(GymClass gymClass) {
    // Create workout tags based on class tags
    final workoutTags = Map<String, bool>.from(state.selectedWorkouts);

    // Update workoutTags with the class tags
    // First reset all workout tags to false
    for (var key in workoutTags.keys) {
      workoutTags[key] = false;
    }

    // Then set true for tags that exist in the class tags and are true
    for (var entry in gymClass.tags.entries) {
      if (workoutTags.containsKey(entry.key) && entry.value) {
        workoutTags[entry.key] = true;
      }
    }

    emit(state.copyWith(
      selectedClass: gymClass,
      selectedWorkouts: workoutTags,
    ));
  }
}
