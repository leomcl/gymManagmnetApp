abstract class WorkoutRepository {
  /// Records a workout session for a user
  ///
  /// [userId] is the unique identifier of the user
  /// [workoutTags] is a map of workout types and whether they were performed
  /// [entryTime] is when the user entered the gym
  /// [exitTime] is when the user exited the gym
  /// [workoutType] is the type of workout
  Future<void> recordWorkout({
    required String userId,
    required Map<String, bool> workoutTags,
    required DateTime entryTime,
    required DateTime exitTime,
    required String workoutType,
  });

  /// Retrieves workout history for a specific user
  ///
  /// [userId] is the unique identifier of the user
  /// [limit] is the maximum number of records to retrieve (optional)
  /// [startDate] optional start date to filter workouts
  /// [endDate] optional end date to filter workouts
  ///
  /// Returns a list of workout sessions
  Future<List<Map<String, dynamic>>> getWorkoutHistory({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets current workout status for a user (if they're in the gym)
  ///
  /// [userId] is the unique identifier of the user
  ///
  /// Returns the entry time if the user is in the gym, null otherwise
  Future<DateTime?> getCurrentWorkoutStartTime(String userId);

  /// Retrieves workouts for all users within a date range
  ///
  /// [startDate] start date to filter workouts
  /// [endDate] end date to filter workouts
  /// [limit] optional maximum number of records to retrieve
  ///
  /// Returns a list of workout sessions
  Future<List<Map<String, dynamic>>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  });
}
