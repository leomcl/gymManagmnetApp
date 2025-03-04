import 'package:test/domain/repositories/auth_repository.dart';
import 'package:test/domain/entities/user.dart';

class GetAuthStateChanges {
  final AuthRepository _authRepository;

  GetAuthStateChanges(this._authRepository);

  Stream<User?> call() {
    return _authRepository.authStateChanges;
  }
}
