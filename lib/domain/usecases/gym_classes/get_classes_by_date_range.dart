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

    // Get classes for each day in the range
    DateTime currentDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime endDay = DateTime(endDate.year, endDate.month, endDate.day);

    while (
        currentDate.isBefore(endDay) || currentDate.isAtSameMomentAs(endDay)) {
      final classesForDay = await repository.getClassesByDate(currentDate);
      allClasses.addAll(classesForDay);

      // Move to next day
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return allClasses;
  }
}
