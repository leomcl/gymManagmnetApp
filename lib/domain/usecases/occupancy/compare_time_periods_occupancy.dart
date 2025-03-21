import '../../../domain/repositories/occupancy_repository.dart';

class CompareTimePeriodsOccupancy {
  final OccupancyRepository repository;

  CompareTimePeriodsOccupancy(this.repository);

  // Compare average occupancy between two time periods
  Future<Map<String, double>> call(DateTime firstStart, DateTime firstEnd,
      DateTime secondStart, DateTime secondEnd) async {
    // Get occupancy for both periods
    final firstPeriod =
        await repository.getOccupancyForDateRange(firstStart, firstEnd);
    final secondPeriod =
        await repository.getOccupancyForDateRange(secondStart, secondEnd);

    // Process first period data
    final Map<String, List<dynamic>> firstPeriodByDate =
        _groupByDate(firstPeriod);
    final List<int> firstPeriodPeaks = _calculateDailyPeaks(firstPeriodByDate);

    // Process second period data
    final Map<String, List<dynamic>> secondPeriodByDate =
        _groupByDate(secondPeriod);
    final List<int> secondPeriodPeaks =
        _calculateDailyPeaks(secondPeriodByDate);

    // Calculate average peak occupancy for first period
    double firstAvg = 0;
    if (firstPeriodPeaks.isNotEmpty) {
      final firstSum = firstPeriodPeaks.reduce((sum, peak) => sum + peak);
      firstAvg = firstSum / firstPeriodPeaks.length;
    }

    // Calculate average peak occupancy for second period
    double secondAvg = 0;
    if (secondPeriodPeaks.isNotEmpty) {
      final secondSum = secondPeriodPeaks.reduce((sum, peak) => sum + peak);
      secondAvg = secondSum / secondPeriodPeaks.length;
    }

    // Calculate percentage change
    double percentChange = 0;
    if (firstAvg > 0) {
      percentChange = ((secondAvg - firstAvg) / firstAvg) * 100;
    }

    return {
      'firstPeriodAvg': firstAvg,
      'secondPeriodAvg': secondAvg,
      'percentChange': percentChange
    };
  }

  // Helper method to group occupancy data by date
  Map<String, List<dynamic>> _groupByDate(List<dynamic> occupancies) {
    final Map<String, List<dynamic>> occupanciesByDate = {};

    for (var occupancy in occupancies) {
      final dateStr =
          '${occupancy.date.year}-${occupancy.date.month}-${occupancy.date.day}';
      if (!occupanciesByDate.containsKey(dateStr)) {
        occupanciesByDate[dateStr] = [];
      }
      occupanciesByDate[dateStr]!.add(occupancy);
    }

    return occupanciesByDate;
  }

  // Helper method to calculate peak occupancy for each day
  List<int> _calculateDailyPeaks(Map<String, List<dynamic>> occupanciesByDate) {
    final List<int> dailyPeaks = [];

    for (var dateOccupancies in occupanciesByDate.values) {
      // Sort by hour to process chronologically
      dateOccupancies.sort((a, b) => a.hour.compareTo(b.hour));

      int cumulativeEntries = 0;
      int cumulativeExits = 0;
      int peakOccupancy = 0;

      for (var occupancy in dateOccupancies) {
        cumulativeEntries += occupancy.entries as int;
        cumulativeExits += occupancy.exits as int;
        final currentOccupancy = cumulativeEntries - cumulativeExits;

        if (currentOccupancy > peakOccupancy) {
          peakOccupancy = currentOccupancy;
        }
      }

      dailyPeaks.add(peakOccupancy);
    }

    return dailyPeaks;
  }
}
