class GymClass {
  final String classId;
  final String className;
  final DateTime classTime;
  final Map<String, bool> tags;

  const GymClass({
    required this.classId,
    required this.className,
    required this.classTime,
    required this.tags,
  });
}
