import 'package:test/data/datasources/firebase_datasource.dart';
import 'package:test/domain/entities/user.dart';
import 'package:test/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Stream<User?> get authStateChanges => dataSource.authStateChanges;

  @override
  User? get currentUser => dataSource.currentUser;

  @override
  Future<void> createUserWithEmailAndPassword(
      String email, String password, String role) {
    return dataSource.createUserWithEmailAndPassword(email, password, role);
  }

  @override
  Future<String?> getUserRole() {
    return dataSource.getUserRole();
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) {
    return dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }
} 