class UserPreferences {
  final String userId;
  final List<int> preferredWorkoutDays; // 1-7 for Monday-Sunday
  final String? preferredTimeOfDay; // "morning", "afternoon", "evening"

  const UserPreferences({
    required this.userId,
    required this.preferredWorkoutDays,
    this.preferredTimeOfDay,
  });
}
