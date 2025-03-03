abstract class GymStatsRepository {
  /// Returns a stream of the current number of people in the gym
  Stream<int> getCurrentGymOccupancy();

  /// Returns hourly attendance data for the chart
  /// TODO: Implement this
  // Future<List<Map<String, dynamic>>> getHourlyAttendance([int? daysBack]);
}
