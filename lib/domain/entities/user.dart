class User {
  final String uid;
  final String email;
  final String? role;
  final bool membershipStatus;

  User({
    required this.uid,
    required this.email,
    this.role,
    this.membershipStatus = false,
  });
} 