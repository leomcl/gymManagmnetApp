import 'package:cloud_firestore/cloud_firestore.dart';

class GymLogManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Log user entry to the gym
  Future<void> logUserEntry(String userId) async {
    CollectionReference logRef = _firestore.collection('gymLogs');
    await logRef.add({
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'eventType': 'entry',
    });
  }

  // Log user exit from the gym
  Future<void> logUserExit(String userId) async {
    CollectionReference logRef = _firestore.collection('gymLogs');
    await logRef.add({
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'eventType': 'exit',
    });
  }
}
