import 'package:test/domain/repositories/workout_repository.dart';

class GetCurrentWorkout {
  final WorkoutRepository repository;

  GetCurrentWorkout(this.repository);

  Future<DateTime?> call(String userId) async {
    return await repository.getCurrentWorkoutStartTime(userId);
  }
} 