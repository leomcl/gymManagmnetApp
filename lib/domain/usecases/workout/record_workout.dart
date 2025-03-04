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
    if (duration.inMinutes < 30) return 'quick';
    if (duration.inHours >= 2) return 'intense';

    // Check specific workout combinations
    final bool isFullBody = tags['Full Body'] ?? false;
    final bool isCardio = tags['Cardio'] ?? false;

    if (isFullBody && isCardio) return 'comprehensive';
    if (isCardio) return 'cardio';
    return 'regular';
  }
}
