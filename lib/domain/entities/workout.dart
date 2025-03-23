class Workout {
  final int day;
  final int dayOfWeek;
  final int duration;
  final DateTime entryTime;
  final DateTime exitTime;
  final int month;
  final String userId;
  final List<String> workoutTags;
  final String workoutType;
  final int year;

  const Workout({
    required this.day,
    required this.dayOfWeek,
    required this.duration,
    required this.entryTime,
    required this.exitTime,
    required this.month,
    required this.userId,
    required this.workoutTags,
    required this.workoutType,
    required this.year,
  });
}
