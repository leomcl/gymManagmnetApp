import 'package:test/domain/repositories/gym_stats_repository.dart';

class GetHourlyEntries {
  final GymStatsRepository repository;

  GetHourlyEntries(this.repository);

  Future<Map<int, int>> call({int daysBack = 0}) {
    return repository.getHourlyAttendanceForToday(daysBack: daysBack);
  }
}
