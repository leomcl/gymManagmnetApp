import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/domain/entities/workout.dart';

class GetWorkoutHistory {
  final WorkoutRepository repository;

  GetWorkoutHistory(this.repository);

  Future<List<Workout>> call({
    required String userId,
    int? limit,
  }) async {
    return await repository.getWorkoutHistory(
      userId: userId,
      limit: limit,
    );
  }
}
