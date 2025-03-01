import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/repositories/access_code_repository.dart';
import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/presentation/bloc/workout/workout_event.dart';
import 'package:test/presentation/bloc/workout/workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository workoutRepository;
  final AccessCodeRepository accessCodeRepository;

  WorkoutBloc({
    required this.workoutRepository,
    required this.accessCodeRepository,
  }) : super(WorkoutState.initial()) {
    on<ToggleWorkoutEvent>(_onToggleWorkout);
    on<SaveWorkoutEvent>(_onSaveWorkout);
    on<GenerateExitCodeEvent>(_onGenerateExitCode);
    on<GenerateCodeEvent>(_onGenerateCode);
  }

  void _onToggleWorkout(
    ToggleWorkoutEvent event,
    Emitter<WorkoutState> emit,
  ) {
    final updatedWorkouts = Map<String, bool>.from(state.selectedWorkouts);
    updatedWorkouts[event.workout] = !updatedWorkouts[event.workout]!;

    emit(state.copyWith(selectedWorkouts: updatedWorkouts));
  }

  Future<void> _onSaveWorkout(
    SaveWorkoutEvent event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final now = DateTime.now();

      await workoutRepository.recordWorkout(
        userId: event.userId,
        workoutTags: state.selectedWorkouts,
        entryTime: state.startTime ?? now,
        exitTime: now,
      );

      emit(state.copyWith(
        isLoading: false,
        startTime: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save workout: ${e.toString()}',
      ));
    }
  }

  Future<void> _onGenerateExitCode(
    GenerateExitCodeEvent event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final exitCode = await accessCodeRepository.generateAccessCode(
        userId: event.userId,
        isEntry: false,
      );

      emit(state.copyWith(
        isLoading: false,
        exitCode: exitCode,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate exit code: ${e.toString()}',
      ));
    }
  }

  Future<void> _onGenerateCode(
    GenerateCodeEvent event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final code = await accessCodeRepository.generateAccessCode(
        userId: event.userId,
        isEntry: event.isEntry,
      );

      if (event.isEntry) {
        emit(state.copyWith(
          isLoading: false,
          entryCode: code,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          exitCode: code,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate code: ${e.toString()}',
      ));
    }
  }
}
