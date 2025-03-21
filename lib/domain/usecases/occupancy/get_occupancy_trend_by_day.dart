import '../../../domain/repositories/occupancy_repository.dart';

class GetOccupancyTrendByDay {
  final OccupancyRepository repository;

  GetOccupancyTrendByDay(this.repository);

  // Returns a map with day of week (1-7, Monday is 1) as key and average occupancy as value
  Future<Map<int, double>> call(DateTime startDate, DateTime endDate) async {
    final occupancies =
        await repository.getOccupancyForDateRange(startDate, endDate);

    // Group occupancies by date to process each day separately
    final Map<String, List<dynamic>> occupanciesByDate = {};

    for (var occupancy in occupancies) {
      final dateStr =
          '${occupancy.date.year}-${occupancy.date.month}-${occupancy.date.day}';
      if (!occupanciesByDate.containsKey(dateStr)) {
        occupanciesByDate[dateStr] = [];
      }
      occupanciesByDate[dateStr]!.add(occupancy);
    }

    // For each date, calculate peak occupancy after accounting for cumulative entries/exits
    final Map<int, List<int>> peakOccupancyByDayOfWeek = {};

    for (var dateStr in occupanciesByDate.keys) {
      final dateOccupancies = occupanciesByDate[dateStr]!;

      // Sort by hour to process chronologically
      dateOccupancies.sort((a, b) => a.hour.compareTo(b.hour));

      int cumulativeEntries = 0;
      int cumulativeExits = 0;
      int peakOccupancy = 0;

      // Find peak occupancy for this day
      for (var occupancy in dateOccupancies) {
        cumulativeEntries += occupancy.entries as int;
        cumulativeExits += occupancy.exits as int;
        final currentOccupancy = cumulativeEntries - cumulativeExits;

        if (currentOccupancy > peakOccupancy) {
          peakOccupancy = currentOccupancy;
        }
      }

      // Store peak occupancy for this day's day of week
      if (dateOccupancies.isNotEmpty) {
        final dayOfWeek = dateOccupancies[0].date.weekday;
        if (!peakOccupancyByDayOfWeek.containsKey(dayOfWeek)) {
          peakOccupancyByDayOfWeek[dayOfWeek] = [];
        }
        peakOccupancyByDayOfWeek[dayOfWeek]!.add(peakOccupancy);
      }
    }

    // Calculate average peak for each day of week
    final Map<int, double> averageByDay = {};
    peakOccupancyByDayOfWeek.forEach((day, values) {
      if (values.isNotEmpty) {
        final sum = values.reduce((a, b) => a + b);
        averageByDay[day] = sum / values.length;
      }
    });

    return averageByDay;
  }
}
