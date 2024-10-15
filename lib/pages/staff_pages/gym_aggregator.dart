import 'package:cloud_firestore/cloud_firestore.dart';

class GymAggregator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update hourly aggregated data when a user enters or exits the gym
  Future<void> updateHourlyGymStats(String eventType, DateTime eventTime) async {
    // Generate the hour bucket in the format "yyyy-MM-dd-HH"
    String hourBucket = '${eventTime.year}-${eventTime.month}-${eventTime.day}-${eventTime.hour}';

    DocumentReference hourlyStatsRef = _firestore.collection('gymHourlyStats').doc(hourBucket);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(hourlyStatsRef);

      if (!snapshot.exists) {
        transaction.set(hourlyStatsRef, {
          'entries': 0,
          'exits': 0,
          'timestamp': eventTime 
        });
      }

      // Fetch the current data from the snapshot
      Map<String, dynamic> data = snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};
      int currentEntries = data['entries'] ?? 0;
      int currentExits = data['exits'] ?? 0;

      // Update the document based on the event type
      if (eventType == 'entry') {
        transaction.update(hourlyStatsRef, {'entries': currentEntries + 1});
      } else if (eventType == 'exit') {
        transaction.update(hourlyStatsRef, {'exits': currentExits + 1});
      }
    });
  }
}
