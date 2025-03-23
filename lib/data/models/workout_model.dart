import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutModel {
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

  WorkoutModel({
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

  factory WorkoutModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;

    // Convert Map<String, bool> to List<String> by keeping only tags with true values
    Map<String, bool> tagsMap =
        Map<String, bool>.from(data['workoutTags'] ?? {});
    List<String> tagsList = tagsMap.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    return WorkoutModel(
      day: data['day'] ?? 0,
      dayOfWeek: data['dayOfWeek'] ?? 0,
      duration: data['duration'] ?? 0,
      entryTime: (data['entryTime'] as Timestamp).toDate(),
      exitTime: (data['exitTime'] as Timestamp).toDate(),
      month: data['month'] ?? 0,
      userId: data['userId'] ?? '',
      workoutTags: tagsList,
      workoutType: data['workoutType'] ?? '',
      year: data['year'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    // Convert List<String> back to Map<String, bool> for Firestore
    Map<String, bool> tagsMap = {for (var tag in workoutTags) tag: true};

    return {
      'day': day,
      'dayOfWeek': dayOfWeek,
      'duration': duration,
      'entryTime': Timestamp.fromDate(entryTime),
      'exitTime': Timestamp.fromDate(exitTime),
      'month': month,
      'userId': userId,
      'workoutTags': tagsMap,
      'workoutType': workoutType,
      'year': year,
    };
  }
}
