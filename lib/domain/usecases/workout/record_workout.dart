import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/domain/repositories/access_code_repository.dart';

class RecordWorkout {
  final WorkoutRepository workoutRepository;
  final AccessCodeRepository accessCodeRepository;

  RecordWorkout(this.workoutRepository, this.accessCodeRepository);

  Future<void> call({
    required String userId,
    required Map<String, bool> workoutTags,
    required DateTime entryTime,
    required DateTime exitTime,
  }) async {
    // Ensure the workout duration is reasonable
    final duration = exitTime.difference(entryTime);

    // Process the workout tags - add intensity based on duration
    final workoutType = _determineWorkoutType(workoutTags, duration);

    // Now record the workout with additional metadata
    return await workoutRepository.recordWorkout(
      userId: userId,
      workoutTags: workoutTags,
      entryTime: entryTime,
      exitTime: exitTime,
      workoutType: workoutType,
    );
  }

  String _determineWorkoutType(Map<String, bool> tags, Duration duration) {
    // Check if this was a class workout
    final bool isClass = tags['Class'] ?? false;
    if (isClass) {
      return 'class';
    }

    // Check specific workout combinations for solo workouts
    final bool isChest = tags['Chest'] ?? false;
    final bool isArms = tags['Arms'] ?? false;
    final bool isBack = tags['Back'] ?? false;

    if (isChest || isArms || isBack) return 'weights';

    final bool isCardio = tags['Cardio'] ?? false;

    if (isCardio) return 'cardio';
    return 'regular';
  }
}
