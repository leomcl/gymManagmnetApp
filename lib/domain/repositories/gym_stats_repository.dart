abstract class GymStatsRepository {
  /// Returns a stream of the current number of people in the gym
  Stream<int> getCurrentGymOccupancy();

  /// Returns hourly attendance data for a specific day
  /// If daysBack is 0, returns data for today
  /// If daysBack is 1, returns data for yesterday, and so on
  Future<Map<int, int>> getHourlyAttendanceForToday({int daysBack = 0});
}
