import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../datasources/firebase_datasource.dart';

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final FirebaseDataSource dataSource;

  UserPreferencesRepositoryImpl(this.dataSource);

  @override
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_preferences')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final data = snapshot.docs.first.data();
      return UserPreferences(
        userId: data['userId'],
        preferredWorkoutDays:
            List<int>.from(data['preferredWorkoutDays'] ?? []),
        preferredTimeOfDay: data['preferredTimeOfDay'],
      );
    } catch (e) {
      print('Error getting user preferences: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_preferences')
          .where('userId', isEqualTo: preferences.userId)
          .get();

      final data = {
        'userId': preferences.userId,
        'preferredWorkoutDays': preferences.preferredWorkoutDays,
        'preferredTimeOfDay': preferences.preferredTimeOfDay,
      };

      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('user_preferences')
            .add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('user_preferences')
            .doc(snapshot.docs.first.id)
            .update(data);
      }
    } catch (e) {
      print('Error saving user preferences: $e');
      throw e;
    }
  }
}
