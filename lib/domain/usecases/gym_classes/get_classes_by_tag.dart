import 'package:test/domain/entities/gym_class.dart';
import 'package:test/domain/repositories/gym_class_repository.dart';

class GetClassesByTag {
  final GymClassRepository repository;

  GetClassesByTag(this.repository);

  Future<List<GymClass>> call(String tag) async {
    return await repository.getClassesByTag(tag);
  }
}
