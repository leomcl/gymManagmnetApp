import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Repositories
import 'package:test/domain/repositories/auth_repository.dart';
import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/domain/repositories/access_code_repository.dart';
import 'package:test/data/repositories/auth_repository_impl.dart';
import 'package:test/data/repositories/workout_repository_impl.dart';
import 'package:test/data/repositories/access_code_repository_impl.dart';

// Data sources
import 'package:test/data/datasources/firebase_datasource.dart';

// Use cases - Auth
import 'package:test/domain/usecases/auth/sign_in.dart';
import 'package:test/domain/usecases/auth/sign_up.dart';
import 'package:test/domain/usecases/auth/sign_out.dart';
import 'package:test/domain/usecases/auth/get_user_role.dart';

// Use cases - Workout
import 'package:test/domain/usecases/workout/record_workout.dart';
import 'package:test/domain/usecases/workout/get_workout_history.dart';
import 'package:test/domain/usecases/workout/get_current_workout.dart';

// Use cases - Access Code
import 'package:test/domain/usecases/access_code/generate_access_code.dart';
import 'package:test/domain/usecases/access_code/validate_access_code.dart';

// BLoCs
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  
  // Cubits
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(
    () => WorkoutCubit(
      workoutRepository: sl(),
      accessCodeRepository: sl(),
    ),
  );

  // Use cases - Auth
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetUserRole(sl()));

  // Use cases - Workout
  sl.registerLazySingleton(() => RecordWorkout(sl()));
  sl.registerLazySingleton(() => GetWorkoutHistory(sl()));
  sl.registerLazySingleton(() => GetCurrentWorkout(sl()));

  // Use cases - Access Code
  sl.registerLazySingleton(() => GenerateAccessCode(sl()));
  sl.registerLazySingleton(() => ValidateAccessCode(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<WorkoutRepository>(() => WorkoutRepositoryImpl());
  sl.registerLazySingleton<AccessCodeRepository>(() => AccessCodeRepositoryImpl());

  // Data sources
  sl.registerLazySingleton(() => FirebaseDataSource(
    auth: sl(),
    firestore: sl(),
  ));

  //! External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
} 