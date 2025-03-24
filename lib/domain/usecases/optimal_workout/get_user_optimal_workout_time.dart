import 'package:test/domain/usecases/optimal_workout/get_user_prefered_day.dart';
import 'package:test/domain/usecases/optimal_workout/get_optimal_workout_times.dart';

class GetUserOptimalWorkoutTime {
  final GetUserPreferedDays getUserPreferedDays;
  final GetOptimalWorkoutTimes getOptimalWorkoutTimes;

  GetUserOptimalWorkoutTime(
      {required this.getUserPreferedDays,
      required this.getOptimalWorkoutTimes});

  Future<List<List<int>>> call(String userId, int limit) async {
    final preferedDays = await getUserPreferedDays(userId, limit);

    final allOptimalTimes = <List<int>>[];

    for (var day in preferedDays) {
      final times = await getOptimalWorkoutTimes.call(day, limit);
      allOptimalTimes.add(times);
    }

    return allOptimalTimes;
  }
}
