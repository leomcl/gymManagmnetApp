import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/usecases/auth/sign_in.dart';
import 'package:test/domain/usecases/auth/sign_up.dart';
import 'package:test/domain/usecases/auth/sign_out.dart';
import 'package:test/domain/usecases/auth/get_user_role.dart';
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:test/domain/usecases/auth/get_auth_state_changes.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn _signInUseCase;
  final SignUp _signUpUseCase;
  final SignOut _signOutUseCase;
  final GetUserRole _getUserRoleUseCase;
  final GetCurrentUser _getCurrentUserUseCase;
  final GetAuthStateChanges _getAuthStateChangesUseCase;
  StreamSubscription? _authSubscription;

  AuthCubit({
    required SignIn signInUseCase,
    required SignUp signUpUseCase,
    required SignOut signOutUseCase,
    required GetUserRole getUserRoleUseCase,
    required GetCurrentUser getCurrentUserUseCase,
    required GetAuthStateChanges getAuthStateChangesUseCase,
  })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getUserRoleUseCase = getUserRoleUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        super(AuthInitial()) {
    // Listen to auth state changes
    _authSubscription = _getAuthStateChangesUseCase().listen((user) {
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
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        final role = await _getUserRoleUseCase();
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
      await _signInUseCase(email, password);
      // We don't need to emit Authenticated here as the stream listener will handle it
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, String role) async {
    emit(AuthLoading());
    try {
      await _signUpUseCase(email, password, role);
      // We don't need to emit Authenticated here as the stream listener will handle it
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _signOutUseCase();
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
