import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccessCodeGenerator {
  static Future<String> generateAndSaveCode({
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

    await FirebaseFirestore.instance
        .collection('gymAccessCodes')
        .doc(code)
        .set({
      'userId': userId,
      'expiryTime': expiryTime,
      'type': isEntry ? 'enter' : 'exit',
    });

    return code;
  }
} 