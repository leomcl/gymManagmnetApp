import 'package:test/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String uid,
    required String email,
    String? role,
    bool membershipStatus = false,
  }) : super(
          uid: uid,
          email: email,
          role: role,
          membershipStatus: membershipStatus,
        );

  factory UserModel.fromFirebaseUser(dynamic firebaseUser, {String? role, bool membershipStatus = false}) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      role: role,
      membershipStatus: membershipStatus,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'],
      membershipStatus: map['membershipStatus'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'membershipStatus': membershipStatus,
    };
  }
} 