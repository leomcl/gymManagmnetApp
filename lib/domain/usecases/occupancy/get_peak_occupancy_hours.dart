import '../../entities/occupancy.dart';
import '../../../domain/repositories/occupancy_repository.dart';

class GetPeakOccupancyHours {
  final OccupancyRepository repository;

  GetPeakOccupancyHours(this.repository);

  Future<List<Occupancy>> call(DateTime date, {int limit = 3}) async {
    final occupancies = await repository.getOccupancyForDate(date);

    // Sort by hour to process chronologically
    occupancies.sort((a, b) => a.hour.compareTo(b.hour));

    // Create a map to store recalculated occupancy for each hour
    final Map<int, Occupancy> hourlyOccupancy = {};

    int cumulativeEntries = 0;
    int cumulativeExits = 0;

    // Calculate cumulative occupancy for each hour
    for (var data in occupancies) {
      cumulativeEntries += data.entries;
      cumulativeExits += data.exits;

      // Create a new Occupancy with the cumulative values
      final updatedOccupancy = Occupancy(
        entries: cumulativeEntries,
        exits: cumulativeExits,
        lastUpdated: data.lastUpdated,
        hourId: data.hourId,
      );

      hourlyOccupancy[data.hour] = updatedOccupancy;
    }

    // Convert to list and sort by occupancy (highest first)
    final recalculatedOccupancies = hourlyOccupancy.values.toList();
    recalculatedOccupancies
        .sort((a, b) => b.currentOccupancy.compareTo(a.currentOccupancy));

    // Return top hours
    return recalculatedOccupancies.take(limit).toList();
  }
}
