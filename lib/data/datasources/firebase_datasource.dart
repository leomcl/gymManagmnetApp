import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:test/data/models/user_model.dart';

class FirebaseDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseDataSource({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
          
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel.fromFirebaseUser(
          firebaseUser,
          role: data['role'],
          membershipStatus: data['membershipStatus'] ?? false,
        );
      }
      
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  UserModel? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password, String role) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final user = userCredential.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'role': role,
        'membershipStatus': false,
      });
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserDoc(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }
} 