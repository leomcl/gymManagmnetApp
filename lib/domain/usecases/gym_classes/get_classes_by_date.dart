import 'package:test/domain/entities/gym_class.dart';
import 'package:test/domain/repositories/gym_class_repository.dart';

class GetClassesByDate {
  final GymClassRepository repository;

  GetClassesByDate(this.repository);

  Future<List<GymClass>> call(DateTime date) async {
    return await repository.getClassesByDate(date);
  }
}
