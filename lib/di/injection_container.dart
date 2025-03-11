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
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:test/domain/usecases/auth/get_auth_state_changes.dart';

// Use cases - Workout
import 'package:test/domain/usecases/workout/record_workout.dart';
import 'package:test/domain/usecases/workout/get_workout_history.dart';
import 'package:test/domain/usecases/workout/get_current_workout.dart';

// Use cases - Access Code
import 'package:test/domain/usecases/access_code/generate_access_code.dart';
import 'package:test/domain/usecases/access_code/validate_access_code.dart';
import 'package:test/domain/usecases/access_code/is_user_in_gym.dart';

// BLoCs
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/gym_stats/gym_stats_cubit.dart';

// Use cases - Gym Stats
import 'package:test/domain/usecases/gym_stats/get_current_gym_occupancy.dart';
import 'package:test/domain/repositories/gym_stats_repository.dart';
import 'package:test/data/repositories/gym_stats_repository_impl.dart';
import 'package:test/domain/usecases/gym_stats/get_hourly_attendance.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features

  // Cubits
  sl.registerFactory(() => AuthCubit(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        getUserRoleUseCase: sl(),
        getCurrentUserUseCase: sl(),
        getAuthStateChangesUseCase: sl(),
      ));
  sl.registerFactory(
    () => WorkoutCubit(
      recordWorkoutUseCase: sl(),
      generateAccessCodeUseCase: sl(),
      getCurrentUserUseCase: sl(),
      isUserInGymUseCase: sl(),
    ),
  );
  sl.registerFactory(() => GymStatsCubit(
        sl<GetCurrentGymOccupancy>(),
        sl<GetHourlyEntries>(),
      ));

  // Use cases - Auth
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetUserRole(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => GetAuthStateChanges(sl()));

  // Use cases - Workout
  sl.registerLazySingleton(
      () => RecordWorkout(sl<WorkoutRepository>(), sl<AccessCodeRepository>()));
  sl.registerLazySingleton(() => GetWorkoutHistory(sl()));
  sl.registerLazySingleton(() => GetCurrentWorkout(sl()));

  // Use cases - Access Code
  sl.registerLazySingleton(() =>
      GenerateAccessCode(sl<AccessCodeRepository>(), sl<AuthRepository>()));
  sl.registerLazySingleton(() => ValidateAccessCode(sl()));
  sl.registerLazySingleton(() => IsUserInGym(sl()));

  // Use cases - Gym Stats
  sl.registerLazySingleton(() => GetCurrentGymOccupancy(sl()));
  sl.registerLazySingleton(() => GetHourlyEntries(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<WorkoutRepository>(() => WorkoutRepositoryImpl());
  sl.registerLazySingleton<AccessCodeRepository>(
      () => AccessCodeRepositoryImpl());
  sl.registerLazySingleton<GymStatsRepository>(() => GymStatsRepositoryImpl());

  // Data sources
  sl.registerLazySingleton(() => FirebaseDataSource(
        auth: sl(),
        firestore: sl(),
      ));

  //! External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
