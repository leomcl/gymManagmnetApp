// use the get_workout_history use case to get the workout history
// calculate prefered workout day based on the workout history
// return the prefered workout day

import 'package:test/domain/usecases/workout/get_workout_history.dart';
import 'package:test/domain/entities/workout.dart';

class GetUserPreferedDays {
  final GetWorkoutHistory getWorkoutHistory;

  GetUserPreferedDays(this.getWorkoutHistory);

  Future<List<int>> call(String userId) async {
    final workoutHistory = await getWorkoutHistory(userId: userId);

    // get the workout history for the last 30 days
    final workoutHistory30Days = workoutHistory
        .where((workout) => workout.entryTime
            .isAfter(DateTime.now().subtract(Duration(days: 30))))
        .toList();

    // calculate the prefered days
    final dayCounts = <int, int>{};

    for (var workout in workoutHistory30Days) {
      final day = workout.dayOfWeek;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    // Sort days by frequency (descending)
    final sortedDays = dayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDays.map((e) => e.key).toList();
  }
}
