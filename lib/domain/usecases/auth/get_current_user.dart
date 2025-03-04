import 'package:test/domain/repositories/auth_repository.dart';
import 'package:test/domain/entities/user.dart';

class GetCurrentUser {
  final AuthRepository _authRepository;

  GetCurrentUser(this._authRepository);

  Future<User?> call() async {
    return _authRepository.currentUser;
  }
} 