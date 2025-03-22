import '../../repositories/occupancy_repository.dart';
import '../../repositories/user_preferences_repository.dart';

class GetOptimalWorkoutTimes {
  final OccupancyRepository occupancyRepository;
  final UserPreferencesRepository preferencesRepository;

  GetOptimalWorkoutTimes({
    required this.occupancyRepository,
    required this.preferencesRepository,
  });

  /// Returns a map with day of week (1-7, Monday is 1) as key and list of optimal hours as value
  /// Each optimal hour is represented as an integer (0-23)
  Future<Map<int, List<int>>> call(String userId,
      {int daysToConsider = 30}) async {
    // Get user preferences
    final userPreferences =
        await preferencesRepository.getUserPreferences(userId);

    if (userPreferences == null ||
        userPreferences.preferredWorkoutDays.isEmpty) {
      throw Exception(
          'User preferences not found or preferred workout days not set');
    }

    // Calculate date range for analysis
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: daysToConsider));

    // Get occupancy data for the date range
    final occupancies =
        await occupancyRepository.getOccupancyForDateRange(startDate, endDate);

    // Group occupancies by day of week and hour
    final Map<int, Map<int, List<int>>> occupancyByDayAndHour = {};

    for (var occupancy in occupancies) {
      final dayOfWeek = occupancy.date.weekday;
      final hour = occupancy.hour;

      if (!occupancyByDayAndHour.containsKey(dayOfWeek)) {
        occupancyByDayAndHour[dayOfWeek] = {};
      }

      if (!occupancyByDayAndHour[dayOfWeek]!.containsKey(hour)) {
        occupancyByDayAndHour[dayOfWeek]![hour] = [];
      }

      occupancyByDayAndHour[dayOfWeek]![hour]!.add(occupancy.currentOccupancy);
    }

    // Calculate average occupancy for each day and hour
    final Map<int, Map<int, double>> averageOccupancyByDayAndHour = {};

    occupancyByDayAndHour.forEach((dayOfWeek, hourMap) {
      averageOccupancyByDayAndHour[dayOfWeek] = {};

      hourMap.forEach((hour, occupancies) {
        if (occupancies.isNotEmpty) {
          final sum = occupancies.reduce((a, b) => a + b);
          averageOccupancyByDayAndHour[dayOfWeek]![hour] =
              sum / occupancies.length;
        }
      });
    });

    // Find the least crowded hours for each preferred day
    final Map<int, List<int>> optimalWorkoutTimes = {};

    for (final day in userPreferences.preferredWorkoutDays) {
      if (averageOccupancyByDayAndHour.containsKey(day)) {
        final Map<int, double> dayOccupancy =
            averageOccupancyByDayAndHour[day]!;

        if (dayOccupancy.isNotEmpty) {
          // Filter hours by time of day preference if specified
          Map<int, double> filteredHours = dayOccupancy;
          if (userPreferences.preferredTimeOfDay != null) {
            filteredHours = _filterByTimeOfDay(
                dayOccupancy, userPreferences.preferredTimeOfDay!);
          }

          // Sort hours by occupancy
          final sortedHours = filteredHours.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value));

          // Take the top 3 least crowded hours
          optimalWorkoutTimes[day] =
              sortedHours.take(3).map((entry) => entry.key).toList();
        }
      }
    }

    return optimalWorkoutTimes;
  }

  Map<int, double> _filterByTimeOfDay(
      Map<int, double> hourOccupancy, String timeOfDay) {
    switch (timeOfDay) {
      case 'morning':
        return Map.fromEntries(hourOccupancy.entries
            .where((entry) => entry.key >= 6 && entry.key < 12));
      case 'afternoon':
        return Map.fromEntries(hourOccupancy.entries
            .where((entry) => entry.key >= 12 && entry.key < 17));
      case 'evening':
        return Map.fromEntries(hourOccupancy.entries
            .where((entry) => entry.key >= 17 && entry.key < 22));
      default:
        return hourOccupancy;
    }
  }
}
