import '../../../domain/entities/occupancy.dart';
import '../../../domain/repositories/occupancy_repository.dart';

class GetCurrentOccupancy {
  final OccupancyRepository repository;

  GetCurrentOccupancy(this.repository);

  Future<int> execute() async {
    final DateTime now = DateTime.now();
    final int currentHour = now.hour;

    // Get all occupancy data for today up to the current hour
    final List<Occupancy> todayData = await repository.getOccupancyForDate(
      DateTime(now.year, now.month, now.day),
    );

    // Calculate the net occupancy by summing all entries and exits up to current hour
    int currentOccupancy = 0;
    for (var data in todayData) {
      if (data.hour <= currentHour) {
        currentOccupancy += data.entries - data.exits;
      }
    }

    return currentOccupancy;
  }
}
