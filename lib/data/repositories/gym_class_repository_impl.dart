import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/data/models/gym_class_model.dart';
import 'package:test/domain/entities/gym_class.dart';
import 'package:test/domain/repositories/gym_class_repository.dart';

class GymClassRepositoryImpl implements GymClassRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'classesMock';

  GymClassRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<GymClass>> getAllClasses() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('dayOfWeek')
          .orderBy('timeOfDay')
          .get();

      return _convertQuerySnapshotToGymClasses(querySnapshot);
    } catch (e) {
      if (e is FirebaseException &&
          e.message != null &&
          e.message!.contains('index')) {
        print(
            'Index required: ${e.message}'); // This will log the link in the console
      }
      throw Exception('Failed to get all classes: $e');
    }
  }

  @override
  Future<GymClass?> getClassById(String classId) async {
    try {
      final documentSnapshot =
          await _firestore.collection(_collectionName).doc(classId).get();

      if (!documentSnapshot.exists) {
        return null;
      }

      final gymClassModel = GymClassModel.fromFirestore(documentSnapshot);
      return gymClassModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get class by ID: $e');
    }
  }

  @override
  Future<List<GymClass>> getClassesByTag(String tag) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('tags.$tag', isEqualTo: true)
          .orderBy('dayOfWeek')
          .orderBy('timeOfDay')
          .get();

      return _convertQuerySnapshotToGymClasses(querySnapshot);
    } catch (e) {
      if (e is FirebaseException &&
          e.message != null &&
          e.message!.contains('index')) {
        print(
            'Index required: ${e.message}'); // This will log the link in the console
      }
      throw Exception('Failed to get classes by tag: $e');
    }
  }

  @override
  Future<List<GymClass>> getClassesByDate(DateTime date) async {
    try {
      // Get the day of week (1-7) from the date
      int dayOfWeek =
          date.weekday; // Using standard 1-7 format where Monday = 1

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('dayOfWeek', isEqualTo: dayOfWeek)
          .orderBy('timeOfDay')
          .get();

      return _convertQuerySnapshotToGymClasses(querySnapshot);
    } catch (e) {
      if (e is FirebaseException &&
          e.message != null &&
          e.message!.contains('index')) {
        print(
            'Index required: ${e.message}'); // This will log the link in the console
      }
      throw Exception('Failed to get classes by date: $e');
    }
  }

  // Helper method to convert QuerySnapshot to List<GymClass>
  List<GymClass> _convertQuerySnapshotToGymClasses(
      QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    return querySnapshot.docs.map((doc) {
      final gymClassModel = GymClassModel.fromFirestore(doc);
      return gymClassModel.toEntity();
    }).toList();
  }
}
