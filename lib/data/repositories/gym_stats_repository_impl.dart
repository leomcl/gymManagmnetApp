import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:test/domain/repositories/gym_stats_repository.dart';

class GymStatsRepositoryImpl implements GymStatsRepository {
  final FirebaseFirestore _firestore;

  GymStatsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<int> getCurrentGymOccupancy() {
    return _firestore.collection('gymHourlyStats').snapshots().map((snapshot) {
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

  @override
  Future<Map<int, int>> getHourlyAttendanceForToday() async {
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final CollectionReference statsCollection =
          _firestore.collection('gymHourlyStats');

      QuerySnapshot snapshot = await statsCollection
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: currentDate)
          .where(FieldPath.documentId, isLessThan: '$currentDate\uFFFF')
          .get();

      Map<int, int> hourlyPeopleCount = {for (int i = 0; i < 24; i++) i: 0};
      int cumulativeCount = 0; // Tracks rolling count of people present

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String docId = doc.id;
        final int hour = int.parse(docId.split('-')[3]);
        final int entries = (data['entries'] ?? 0) as int;
        final int exits = (data['exits'] ?? 0) as int;

        final int netChange = entries - exits;
        cumulativeCount += netChange;
        hourlyPeopleCount[hour] = cumulativeCount;
      }

      for (int i = 1; i < 24; i++) {
        if (hourlyPeopleCount[i] == 0) {
          hourlyPeopleCount[i] = hourlyPeopleCount[i - 1] ?? 0;
        }
      }

      return hourlyPeopleCount;
    } catch (e) {
      print('Error getting hourly entries: $e');
      return {};
    }
  }
}
