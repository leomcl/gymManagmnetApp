import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser {
    return _auth.currentUser;
  }

  // Stream to listen to authentication changes
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Create a new account with email, password, and role
  Future<void> createUserWithEmailAndPassword(
      String email, String password, String role) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      // Store the user information and role in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'role': role,
        'membershipStatus': false,  // Default membership status
      });
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get the user role from Firestore
  Future<String?> getUserRole() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc['role'] as String;
      }
    }
    return null;
  }
}
