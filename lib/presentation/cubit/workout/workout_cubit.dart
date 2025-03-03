import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/repositories/access_code_repository.dart';
import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';
import 'package:test/domain/repositories/auth_repository.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutRepository workoutRepository;
  final AccessCodeRepository accessCodeRepository;
  final AuthRepository _authRepository;

  WorkoutCubit({
    required this.workoutRepository,
    required this.accessCodeRepository,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(WorkoutState.initial());

  void toggleWorkout(String workout) {
    final updatedWorkouts = Map<String, bool>.from(state.selectedWorkouts);
    updatedWorkouts[workout] = !updatedWorkouts[workout]!;

    emit(state.copyWith(selectedWorkouts: updatedWorkouts));
  }

  Future<void> saveWorkout(String userId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final now = DateTime.now();

      await workoutRepository.recordWorkout(
        userId: userId,
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

  Future<void> generateExitCode(String userId) async {
    try {
      emit(state.copyWith(isLoading: true));

      final exitCode = await accessCodeRepository.generateAccessCode(
        userId: userId,
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

  Future<void> generateCode(
      {required String userId, required bool isEntry}) async {
    try {
      emit(state.copyWith(isLoading: true));

      final code = await accessCodeRepository.generateAccessCode(
        userId: userId,
        isEntry: isEntry,
      );

      if (isEntry) {
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

  Future<void> handleGymExit() async {
    final userId = _authRepository.currentUser?.uid;
    if (userId != null) {
      saveWorkout(userId);
      generateExitCode(userId);
    } else {
      emit(state.copyWith(errorMessage: 'User not found'));
    }
  }
}
