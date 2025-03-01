import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/domain/repositories/access_code_repository.dart';
import 'dart:math';

class AccessCodeRepositoryImpl implements AccessCodeRepository {
  final FirebaseFirestore _firestore;

  AccessCodeRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> generateAccessCode({
    required String userId,
    required bool isEntry,
    Duration expiry = const Duration(hours: 1),
  }) async {
    final Random random = Random();
    String code;

    // Generate a random even or odd 6-digit code based on isEntry flag
    if (isEntry) {
      code = ((random.nextInt(450000) * 2) + 100000).toString(); // Even number
    } else {
      code = ((random.nextInt(450000) * 2) + 100001).toString(); // Odd number
    }

    final DateTime expiryTime = DateTime.now().add(expiry);

    await _firestore.collection('gymAccessCodes').doc(code).set({
      'userId': userId,
      'expiryTime': expiryTime,
      'type': isEntry ? 'enter' : 'exit',
    });

    return code;
  }

  @override
  Future<bool> validateAccessCode({
    required String code,
    required bool isEntry,
  }) async {
    try {
      // Fetch the document from Firestore
      DocumentSnapshot doc =
          await _firestore.collection('gymAccessCodes').doc(code).get();

      if (!doc.exists) {
        return false;
      }

      // Check if code is of correct type (entry or exit)
      final data = doc.data() as Map<String, dynamic>;
      if ((data['type'] == 'enter') != isEntry) {
        return false;
      }

      // Check if code has expired
      final expiration = (data['expiryTime'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiration)) {
        // Optionally delete expired codes
        await _firestore.collection('gymAccessCodes').doc(code).delete();
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating access code: $e');
      return false;
    }
  }
}
