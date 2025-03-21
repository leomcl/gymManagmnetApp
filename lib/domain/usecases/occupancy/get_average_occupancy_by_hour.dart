import '../../../domain/repositories/occupancy_repository.dart';

class GetAverageOccupancyByHour {
  final OccupancyRepository repository;

  GetAverageOccupancyByHour(this.repository);

  // Returns a map with hour (0-23) as key and average occupancy as value
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

    // For each date, calculate cumulative occupancy for each hour
    final Map<int, List<int>> recalculatedOccupanciesByHour = {};

    for (var dateOccupancies in occupanciesByDate.values) {
      // Sort by hour to process chronologically
      dateOccupancies.sort((a, b) => a.hour.compareTo(b.hour));

      int cumulativeEntries = 0;
      int cumulativeExits = 0;

      for (var occupancy in dateOccupancies) {
        cumulativeEntries += occupancy.entries as int;
        cumulativeExits += occupancy.exits as int;
        final currentOccupancy = cumulativeEntries - cumulativeExits;

        final hour = occupancy.hour;
        if (!recalculatedOccupanciesByHour.containsKey(hour)) {
          recalculatedOccupanciesByHour[hour] = [];
        }
        recalculatedOccupanciesByHour[hour]!.add(currentOccupancy);
      }
    }

    // Calculate average for each hour
    final Map<int, double> averageByHour = {};
    recalculatedOccupanciesByHour.forEach((hour, values) {
      if (values.isNotEmpty) {
        final sum = values.reduce((a, b) => a + b);
        averageByHour[hour] = sum / values.length;
      }
    });

    return averageByHour;
  }
}
