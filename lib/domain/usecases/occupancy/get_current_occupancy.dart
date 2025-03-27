import '../../../domain/entities/occupancy.dart';
import '../../../domain/repositories/occupancy_repository.dart';

class GetCurrentOccupancy {
  final OccupancyRepository repository;

  GetCurrentOccupancy(this.repository);

  Future<int> execute() async {
    // Instead of calculating occupancy based on entries and exits,
    // simply count the number of documents in the usersInGym collection
    final int currentOccupancy = await repository.countUsersCurrentlyInGym();

    return currentOccupancy;
  }
}
