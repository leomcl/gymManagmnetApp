import 'package:test/domain/entities/gym_class.dart';
import 'package:test/domain/repositories/gym_class_repository.dart';

class GetClassesByDateRange {
  final GymClassRepository repository;

  GetClassesByDateRange(this.repository);

  Future<List<GymClass>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final List<GymClass> allClasses = [];
    final Set<int> daysToFetch = {};

    // Get the list of days we need to fetch
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      // Convert weekday (1-7, Monday-Sunday) to our format (0-6)
      int dayOfWeek = currentDate.weekday - 1;
      daysToFetch.add(dayOfWeek);

      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Fetch all classes
    final allAvailableClasses = await repository.getAllClasses();

    // Filter classes by days in our range
    for (var gymClass in allAvailableClasses) {
      if (daysToFetch.contains(gymClass.dayOfWeek)) {
        allClasses.add(gymClass);
      }
    }

    return allClasses;
  }
}
