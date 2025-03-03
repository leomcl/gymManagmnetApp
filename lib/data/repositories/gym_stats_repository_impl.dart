import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/domain/repositories/gym_stats_repository.dart';

class GymStatsRepositoryImpl implements GymStatsRepository {
  final FirebaseFirestore _firestore;
  
  GymStatsRepositoryImpl({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Stream<int> getCurrentGymOccupancy() {
    return _firestore
        .collection('gymHourlyStats')
        .snapshots()
        .map((snapshot) {
      int totalCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        int entries = data['entries'] ?? 0;
        int exits = data['exits'] ?? 0;
        totalCount += entries - exits;
      }
      return totalCount;
    });
  }
  
  /// TODO: Implement this
  // @override
  // Future<List<Map<String, dynamic>>> getHourlyAttendance([int? daysBack = 1]) {
    // Implementation for getting hourly attendance data
    // ...

  // }
} 