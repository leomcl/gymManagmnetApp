import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String userId;
  final String role;
  final String email;
  final bool membershipStatus;

  const Authenticated({
    required this.userId,
    required this.role,
    required this.email,
    required this.membershipStatus,
  });

  @override
  List<Object?> get props => [userId, role, email, membershipStatus];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
} 