import 'package:test/domain/repositories/auth_repository.dart';

class GetUserRole {
  final AuthRepository repository;

  GetUserRole(this.repository);

  Future<String?> call() async {
    return await repository.getUserRole();
  }
} 