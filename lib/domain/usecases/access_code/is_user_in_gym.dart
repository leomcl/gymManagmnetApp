import 'package:test/domain/repositories/access_code_repository.dart';

class IsUserInGym {
  final AccessCodeRepository repository;

  IsUserInGym(this.repository);

  Future<bool> call({required String userId}) async {
    return await repository.isUserInGym(userId: userId);
  }
}
