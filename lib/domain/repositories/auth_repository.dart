import 'package:test/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  Future<User?> get currentUser;
  
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(
      String email, String password, String role);
  Future<void> signOut();
  Future<String?> getUserRole();
  Future<User?> getUserById(String userId);
}   