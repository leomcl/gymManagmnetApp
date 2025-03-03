import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/repositories/auth_repository.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    // Listen to auth state changes
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        checkAuthStatus();
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        final role = await _authRepository.getUserRole();
        emit(Authenticated(
          userId: user.uid,
          role: role ?? 'unknown',
          email: user.email,
        ));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(
        email,
        password,
      );
      // We don't need to emit Authenticated here as the stream listener will handle it
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String role) async {
    emit(AuthLoading());
    try {
      await _authRepository.createUserWithEmailAndPassword(
        email,
        password,
        role,
      );
      // We don't need to emit Authenticated here as the stream listener will handle it
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
} 