import 'package:test/domain/entities/gym_class.dart';

abstract class GymClassRepository {
  /// Get all gym classes
  Future<List<GymClass>> getAllClasses();

  /// Get a specific gym class by ID
  Future<GymClass?> getClassById(String classId);

  /// Get classes by tag (classes that have the specified tag set to true)
  Future<List<GymClass>> getClassesByTag(String tag);

  /// Get classes scheduled for a specific date
  Future<List<GymClass>> getClassesByDate(DateTime date);

}
