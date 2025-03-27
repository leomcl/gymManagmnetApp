import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/occupancy.dart';
import '../../domain/repositories/occupancy_repository.dart';
import '../models/occupancy_model.dart';

class OccupancyRepositoryImpl implements OccupancyRepository {
  final FirebaseFirestore _firestore;
  final String _collectionName = 'gymHourlyStatsMock';

  OccupancyRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Occupancy> getOccupancyForHour(DateTime dateTime) async {
    try {
      final docId = _createDocId(dateTime);
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(docId).get();

      if (!docSnapshot.exists) {
        throw Exception('No occupancy data found for specified hour');
      }

      final occupancyModel = OccupancyModel.fromFirestore(docSnapshot, null);
      return _modelToEntity(occupancyModel);
    } catch (e) {
      throw Exception('Failed to get occupancy data: $e');
    }
  }

  @override
  Future<List<Occupancy>> getOccupancyForDate(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$dateStr-00')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$dateStr-23')
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No occupancy data found for specified date');
      }

      final occupancies = querySnapshot.docs
          .map((doc) => _modelToEntity(OccupancyModel.fromFirestore(doc, null)))
          .toList();

      return occupancies;
    } catch (e) {
      throw Exception('Failed to get occupancy data: $e');
    }
  }

  @override
  Future<List<Occupancy>> getOccupancyForDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);

      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$startStr-00')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$endStr-23')
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No occupancy data found for specified date range');
      }

      final occupancies = querySnapshot.docs
          .map((doc) => _modelToEntity(OccupancyModel.fromFirestore(doc, null)))
          .toList();

      return occupancies;
    } catch (e) {
      throw Exception('Failed to get occupancy data: $e');
    }
  }

  // Helper methods
  String _createDocId(DateTime dateTime) {
    return '${DateFormat('yyyy-MM-dd').format(dateTime)}-${dateTime.hour.toString().padLeft(2, '0')}';
  }

  Occupancy _modelToEntity(OccupancyModel model) {
    return Occupancy(
      entries: model.entries,
      exits: model.exits,
      lastUpdated: model.lastUpdated,
      hourId: model.hourId,
    );
  }
}
