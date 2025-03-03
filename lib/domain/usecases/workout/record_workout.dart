import 'package:test/domain/repositories/workout_repository.dart';

class RecordWorkout {
  final WorkoutRepository repository;

  RecordWorkout(this.repository);

  Future<void> call({
    required String userId,
    required Map<String, bool> workoutTags,
    required DateTime entryTime,
    required DateTime exitTime,
  }) async {
    return await repository.recordWorkout(
      userId: userId,
      workoutTags: workoutTags,
      entryTime: entryTime,
      exitTime: exitTime,
    );
  }
} 