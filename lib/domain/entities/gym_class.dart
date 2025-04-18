class GymClass {
  final String classId;
  final String className;
  final int dayOfWeek; // 1 (Monday) to 7 (Sunday), matching DateTime.weekday
  final int timeOfDay; // Minutes since midnight (e.g., 8:30 AM = 510 minutes)
  final Map<String, bool> tags;

  const GymClass({
    required this.classId,
    required this.className,
    required this.dayOfWeek,
    required this.timeOfDay,
    required this.tags,
  });

  // Backward compatibility getter for UI
  DateTime get classTime {
    // Create a DateTime combining the current date with the time
    final now = DateTime.now();
    // Adjust to the correct day of week (using 1-7 format, same as DateTime.weekday)
    final daysToAdd = (dayOfWeek - now.weekday) % 7;
    final date = now.add(Duration(days: daysToAdd));

    // Convert minutes since midnight to hours and minutes
    final hours = timeOfDay ~/ 60;
    final minutes = timeOfDay % 60;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hours,
      minutes,
    );
  }
}
