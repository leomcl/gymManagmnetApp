import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/domain/repositories/workout_repository.dart';

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
  }) async {
    final duration = exitTime.difference(entryTime).inMinutes;
    
    // Create a document ID using user ID and timestamp
    final docId = '${userId}_${entryTime.toIso8601String()}';
    
    await _firestore.collection('gymUsageHistory').doc(docId).set({
      'userId': userId,
      'entryTime': entryTime,
      'exitTime': exitTime,
      'duration': duration,
      'workoutTags': workoutTags,
      'workoutType': 'regular',
    });
  }
  
  @override
  Future<List<Map<String, dynamic>>> getWorkoutHistory({
    required String userId,
    int? limit,
  }) async {
    Query query = _firestore
        .collection('gymUsageHistory')
        .where('userId', isEqualTo: userId)
        .orderBy('entryTime', descending: true);
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    final QuerySnapshot snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'entryTime': (data['entryTime'] as Timestamp).toDate(),
        'exitTime': (data['exitTime'] as Timestamp).toDate(),
        'duration': data['duration'],
        'workoutTags': data['workoutTags'],
        'workoutType': data['workoutType'],
      };
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
} 