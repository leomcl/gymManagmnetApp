import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/domain/entities/workout.dart';
import 'package:test/data/models/workout_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final FirebaseFirestore _firestore;

  WorkoutRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> recordWorkout({
    required String userId,
    required Map<String, bool> workoutTags,
    required DateTime entryTime,
    required DateTime exitTime,
    required String workoutType,
  }) async {
    final duration = exitTime.difference(entryTime).inMinutes;

    await _firestore.collection('gymUsageHistory').add({
      'userId': userId,
      'entryTime': Timestamp.fromDate(entryTime),
      'exitTime': Timestamp.fromDate(exitTime),
      'duration': duration,
      'workoutTags': workoutTags,
      'workoutType': workoutType,
      // Add additional fields that might be useful for queries
      'year': entryTime.year,
      'month': entryTime.month,
      'day': entryTime.day,
      'dayOfWeek': entryTime.weekday,
    });
  }

  @override
  Future<List<Workout>> getWorkoutHistory({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection('gymUsageHistory');

    // Add filters based on parameters
    if (userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }

    if (startDate != null) {
      query = query.where('entryTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('entryTime',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    // Always order by entryTime for consistency
    query = query.orderBy('entryTime', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final QuerySnapshot snapshot = await query.get();

    // Convert to WorkoutModel and then to Workout entities
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Get workoutTags as List<String>
      Map<String, bool> tagsMap =
          Map<String, bool>.from(data['workoutTags'] ?? {});
      List<String> tagsList = tagsMap.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      // Create and return the entity
      return Workout(
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
    }).toList();
  }

  @override
  Future<DateTime?> getCurrentWorkoutStartTime(String userId) async {
    // Look for any workout sessions that don't have an exit time
    final QuerySnapshot snapshot = await _firestore
        .collection('activeGymSessions')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return (data['entryTime'] as Timestamp).toDate();
  }

  // New method for querying workouts by date range (all users)
  Future<List<Workout>> getWorkoutsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) async {
    Query query = _firestore
        .collection('gymUsageHistory')
        .where('entryTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('entryTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('entryTime', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final QuerySnapshot snapshot = await query.get();

    // Convert to WorkoutModel and then to Workout entities
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Get workoutTags as List<String>
      Map<String, bool> tagsMap =
          Map<String, bool>.from(data['workoutTags'] ?? {});
      List<String> tagsList = tagsMap.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      // Create and return the entity
      return Workout(
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
    }).toList();
  }
}
