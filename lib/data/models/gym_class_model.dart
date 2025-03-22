import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/domain/entities/gym_class.dart';

class GymClassModel {
  final String classId;
  final String className;
  final DateTime classTime;
  final Map<String, bool> tags;

  GymClassModel({
    required this.classId,
    required this.className,
    required this.classTime,
    required this.tags,
  });

  // Convert Firestore document to GymClassModel
  factory GymClassModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      [SnapshotOptions? options]) {
    final data = snapshot.data()!;

    return GymClassModel(
      classId: snapshot.id,
      className: data['className'] ?? '',
      classTime: (data['classTime'] as Timestamp).toDate(),
      tags: Map<String, bool>.from(data['tags'] ?? {}),
    );
  }

  // Convert GymClassModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'className': className,
      'classTime': Timestamp.fromDate(classTime),
      'tags': tags,
    };
  }

  // Convert GymClassModel to GymClass entity
  GymClass toEntity() {
    return GymClass(
      classId: classId,
      className: className,
      classTime: classTime,
      tags: tags,
    );
  }

  // Create GymClassModel from GymClass entity
  factory GymClassModel.fromEntity(GymClass gymClass) {
    return GymClassModel(
      classId: gymClass.classId,
      className: gymClass.className,
      classTime: gymClass.classTime,
      tags: gymClass.tags,
    );
  }
}
