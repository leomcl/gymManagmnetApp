import 'package:cloud_firestore/cloud_firestore.dart';

class OccupancyModel {
  final int entries;
  final int exits;
  final DateTime lastUpdated;
  final String hourId; // Represents the document ID format "YYYY-MM-DD-HH"

  // Calculated property
  int get currentOccupancy => entries - exits;

  const OccupancyModel({
    required this.entries,
    required this.exits,
    required this.lastUpdated,
    required this.hourId,
  });

  // Convert Firestore document to OccupancyModel
  factory OccupancyModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return OccupancyModel(
      entries: data?['entries'] ?? 0,
      exits: data?['exits'] ?? 0,
      lastUpdated:
          (data?['last_updated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hourId: snapshot.id,
    );
  }

  // Convert OccupancyModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'entries': entries,
      'exits': exits,
      'last_updated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Parse date and hour from hourId
  DateTime get date {
    final parts = hourId.split('-');
    if (parts.length >= 3) {
      final dateStr = parts.sublist(0, 3).join('-');
      return DateTime.parse(dateStr);
    }
    return DateTime.now();
  }

  // Get the hour from the hourId
  int get hour {
    final parts = hourId.split('-');
    if (parts.length >= 4) {
      return int.tryParse(parts[3]) ?? 0;
    }
    return 0;
  }

  // Create a copy of this model with updated fields
  OccupancyModel copyWith({
    int? entries,
    int? exits,
    DateTime? lastUpdated,
    String? hourId,
  }) {
    return OccupancyModel(
      entries: entries ?? this.entries,
      exits: exits ?? this.exits,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hourId: hourId ?? this.hourId,
    );
  }
}
