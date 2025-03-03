import 'package:test/domain/repositories/workout_repository.dart';

class GetWorkoutHistory {
  final WorkoutRepository repository;

  GetWorkoutHistory(this.repository);

  Future<List<Map<String, dynamic>>> call({
    required String userId,
    int? limit,
  }) async {
    return await repository.getWorkoutHistory(
      userId: userId,
      limit: limit,
    );
  }
} 