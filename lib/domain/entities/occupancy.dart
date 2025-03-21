class Occupancy {
  final int entries;
  final int exits;
  final DateTime lastUpdated;
  final String hourId;

  // Calculated property for current occupancy
  int get currentOccupancy => entries - exits;

  // Date parsed from hourId (YYYY-MM-DD-HH)
  DateTime get date {
    final parts = hourId.split('-');
    if (parts.length >= 3) {
      final dateStr = parts.sublist(0, 3).join('-');
      return DateTime.parse(dateStr);
    }
    return DateTime.now();
  }

  // Hour extracted from hourId
  int get hour {
    final parts = hourId.split('-');
    if (parts.length >= 4) {
      return int.tryParse(parts[3]) ?? 0;
    }
    return 0;
  }

  const Occupancy({
    required this.entries,
    required this.exits,
    required this.lastUpdated,
    required this.hourId,
  });
}
