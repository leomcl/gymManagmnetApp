import '../../repositories/occupancy_repository.dart';

class GetOptimalWorkoutTimes {
  final OccupancyRepository occupancyRepository;

  GetOptimalWorkoutTimes({
    required this.occupancyRepository,
  });

  /// Returns a list of optimal hours for the specified day
  /// Each optimal hour is represented as an integer (0-23)
  /// day parameter should be between 1-7 (Monday is 1)
  Future<List<int>> call(int day, int limit,
      {int daysToConsider = 30}) async {
    if (day < 1 || day > 7) {
      throw ArgumentError('Day must be between 1 and 7, where Monday is 1');
    }

    // Calculate date range for analysis
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysToConsider));

    // Get occupancy data for the date range
    final occupancies =
        await occupancyRepository.getOccupancyForDateRange(startDate, endDate);

    // Collect occupancies only for the specified day
    final Map<int, List<int>> occupancyByHour = {};

    for (var occupancy in occupancies) {
      if (occupancy.date.weekday == day) {
        final hour = occupancy.hour;

        if (!occupancyByHour.containsKey(hour)) {
          occupancyByHour[hour] = [];
        }

        occupancyByHour[hour]!.add(occupancy.currentOccupancy);
      }
    }

    // Calculate average occupancy for each hour
    final Map<int, double> averageOccupancyByHour = {};

    occupancyByHour.forEach((hour, occupancies) {
      if (occupancies.isNotEmpty) {
        final sum = occupancies.reduce((a, b) => a + b);
        averageOccupancyByHour[hour] = sum / occupancies.length;
      }
    });

    if (averageOccupancyByHour.isEmpty) {
      return [];
    }

    // Sort hours by occupancy
    final sortedHours = averageOccupancyByHour.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Take the top N least crowded hours or all available if less than limit
    return sortedHours.take(limit).map((entry) => entry.key).toList();
  }
}
