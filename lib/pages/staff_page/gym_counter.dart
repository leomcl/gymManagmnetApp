import 'package:cloud_firestore/cloud_firestore.dart';

class GymCounter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to increment the gym count (when a valid access code is used for entry)
  Future<void> incrementGymCount() async {
    DocumentReference gymStatusRef =
        _firestore.collection('gymStatus').doc('currentCount');

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gymStatusRef);

      if (!snapshot.exists) {
        // If the document doesn't exist, create it with an initial value of 1
        transaction.set(gymStatusRef, {'currentCount': 1});
      } else {
        // Safely retrieve and increment the count, defaulting to 0 if currentCount is null
        int currentCount = (snapshot.data() as Map<String, dynamic>)['currentCount'] ?? 0;
        transaction.update(gymStatusRef, {'currentCount': currentCount + 1});
      }
    });
  }

  // Function to decrement the gym count (when a user exits)
  Future<void> decrementGymCount() async {
    DocumentReference gymStatusRef =
        _firestore.collection('gymStatus').doc('currentCount');

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(gymStatusRef);

      if (!snapshot.exists) {
        // If the document doesn't exist, set the initial count to 0
        transaction.set(gymStatusRef, {'currentCount': 0});
      } else {
        // Safely retrieve the current count, defaulting to 0 if currentCount is null
        int currentCount = (snapshot.data() as Map<String, dynamic>)['currentCount'] ?? 0;
        // Decrement the count, ensuring it doesn't go below zero
        int newCount = currentCount > 0 ? currentCount - 1 : 0;
        transaction.update(gymStatusRef, {'currentCount': newCount});
      }
    });
  }

  // Function to get the current number of people in the gym
  Stream<DocumentSnapshot> getCurrentGymCount() {
    return _firestore.collection('gymStatus').doc('currentCount').snapshots();
  }
}
