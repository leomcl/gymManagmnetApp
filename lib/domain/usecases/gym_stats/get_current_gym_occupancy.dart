import 'package:test/domain/repositories/gym_stats_repository.dart';

class GetCurrentGymOccupancy {
  final GymStatsRepository repository;

  GetCurrentGymOccupancy(this.repository);

  Stream<int> call() {
    return repository.getCurrentGymOccupancy();
  }
} 