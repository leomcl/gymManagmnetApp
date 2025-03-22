class FormatOptimalWorkoutTimes {
  /// Formats the optimal workout times map into a user-friendly string
  /// Input is a map with day of week (1-7, Monday is 1) as key and list of optimal hours as value
  String call(Map<int, List<int>> optimalWorkoutTimes) {
    if (optimalWorkoutTimes.isEmpty) {
      return 'No optimal workout times found based on your preferences.';
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln(
        'Based on gym occupancy data, here are your optimal workout times:');
    buffer.writeln();

    final daysOfWeek = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };

    // Sort by day of week
    final sortedDays = optimalWorkoutTimes.keys.toList()..sort();

    for (final day in sortedDays) {
      buffer.writeln('${daysOfWeek[day]}:');

      final hours = optimalWorkoutTimes[day]!;
      if (hours.isEmpty) {
        buffer.writeln('  No optimal times found for this day.');
      } else {
        for (final hour in hours) {
          buffer.writeln('  ${_formatHour(hour)} - Typically less crowded');
        }
      }
      buffer.writeln();
    }

    buffer.writeln(
        'These recommendations are based on historical gym occupancy data.');
    return buffer.toString();
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 $period';
  }
}
