import 'package:test/domain/repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<void> call(String email, String password) async {
    return await repository.signInWithEmailAndPassword(email, password);
  }
} 