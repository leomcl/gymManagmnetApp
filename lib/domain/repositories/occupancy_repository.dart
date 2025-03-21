import '../entities/occupancy.dart';

abstract class OccupancyRepository {
  /// Get occupancy for a specific date and hour
  Future<Occupancy> getOccupancyForHour(DateTime dateTime);

  /// Get occupancy records for a specific date
  Future<List<Occupancy>> getOccupancyForDate(DateTime date);

  /// Get occupancy records for a date range
  Future<List<Occupancy>> getOccupancyForDateRange(
      DateTime startDate, DateTime endDate);
}
