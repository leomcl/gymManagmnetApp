import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Repositories
import 'package:test/domain/repositories/auth_repository.dart';
import 'package:test/domain/repositories/workout_repository.dart';
import 'package:test/domain/repositories/access_code_repository.dart';
import 'package:test/domain/repositories/occupancy_repository.dart';
import 'package:test/data/repositories/auth_repository_impl.dart';
import 'package:test/data/repositories/workout_repository_impl.dart';
import 'package:test/data/repositories/access_code_repository_impl.dart';
import 'package:test/data/repositories/occupancy_repository_impl.dart';

// repositories - Gym Classes
import 'package:test/domain/repositories/gym_class_repository.dart';
import 'package:test/data/repositories/gym_class_repository_impl.dart';

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

// Use cases - Gym Stats
import 'package:test/domain/usecases/occupancy/compare_time_periods_occupancy.dart';
import 'package:test/domain/usecases/occupancy/get_peak_occupancy_hours.dart';
import 'package:test/domain/usecases/occupancy/get_current_occupancy.dart';
import 'package:test/domain/usecases/occupancy/get_average_occupancy_by_hour.dart';
import 'package:test/domain/usecases/occupancy/get_occupancy_trend_by_day.dart';

// Use cases - Gym Classes
import 'package:test/domain/usecases/gym_classes/get_all_classes.dart';
import 'package:test/domain/usecases/gym_classes/get_class_by_id.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_date.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_tag.dart';
import 'package:test/domain/usecases/gym_classes/get_classes_by_date_range.dart';

// Use cases - Optimal Workout
import 'package:test/domain/usecases/user_trends/get_optimal_workout_times.dart';
import 'package:test/domain/usecases/user_trends/get_user_prefered_workout.dart';
import 'package:test/domain/usecases/user_trends/get_user_prefered_day.dart';
import 'package:test/domain/usecases/user_trends/get_class_suggestion.dart';

// BLoCs
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout_stats/cubit/workout_stats_cubit.dart';
import 'package:test/presentation/cubit/occupancy/occupancy_cubit.dart';
import 'package:test/presentation/cubit/gym_classes/gym_classes_cubit.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_cubit.dart';
import 'package:test/presentation/cubit/suggestions/suggestions_cubit.dart';
import 'package:test/presentation/cubit/profile/profile_cubit.dart';

// Use cases - Gym Stats
import 'package:test/domain/repositories/gym_stats_repository.dart';
import 'package:test/data/repositories/gym_stats_repository_impl.dart';

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
  sl.registerFactory(() => WorkoutSelectionCubit(
        getClassesByDate: sl(),
      ));

  sl.registerFactory(
    () => WorkoutStatsCubit(
      workoutRepository: sl<WorkoutRepository>(),
      getCurrentUser: sl<GetCurrentUser>(),
    ),
  );
  sl.registerFactory(() => SuggestionsCubit(
        getOptimalWorkoutTimes: sl(),
        getCurrentUser: sl(),
        getUserPreferedWorkout: sl(),
        getUserPreferedDays: sl(),
        getClassSuggestion: sl(),
      ));
  sl.registerLazySingleton<OccupancyRepository>(() => OccupancyRepositoryImpl(
        firestore: sl<FirebaseFirestore>(),
      ));

  // Use cases - Auth
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetUserRole(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => GetAuthStateChanges(sl()));

  // Use cases - Occupancy
  sl.registerLazySingleton(() => GetCurrentOccupancy(sl()));
  sl.registerLazySingleton(() => GetPeakOccupancyHours(sl()));
  sl.registerLazySingleton(() => GetAverageOccupancyByHour(sl()));
  sl.registerLazySingleton(() => GetOccupancyTrendByDay(sl()));
  sl.registerLazySingleton(() => CompareTimePeriodsOccupancy(sl()));

  // Use cases - Optimal Workout
  sl.registerLazySingleton(() => GetOptimalWorkoutTimes(
        occupancyRepository: sl<OccupancyRepository>(),
      ));
  sl.registerLazySingleton(
      () => GetUserPreferedWorkout(sl<GetWorkoutHistory>()));
  sl.registerLazySingleton(() => GetUserPreferedDays(sl<GetWorkoutHistory>()));
  sl.registerLazySingleton(() => GetClassSuggestion(
        gymClassRepository: sl<GymClassRepository>(),
        getClassesByDateRange: sl<GetClassesByDateRange>(),
        getUserPreferedDays: sl<GetUserPreferedDays>(),
        getUserPreferedWorkout: sl<GetUserPreferedWorkout>(),
      ));

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

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<WorkoutRepository>(() => WorkoutRepositoryImpl());
  sl.registerLazySingleton<AccessCodeRepository>(
      () => AccessCodeRepositoryImpl());
  sl.registerLazySingleton<GymStatsRepository>(() => GymStatsRepositoryImpl());
  sl.registerLazySingleton<GymClassRepository>(() => GymClassRepositoryImpl(
        firestore: sl<FirebaseFirestore>(),
      ));

  // Use cases - Gym Classes
  sl.registerLazySingleton(() => GetAllClasses(sl()));
  sl.registerLazySingleton(() => GetClassById(sl()));
  sl.registerLazySingleton(() => GetClassesByDate(sl()));
  sl.registerLazySingleton(() => GetClassesByTag(sl()));
  sl.registerLazySingleton(() => GetClassesByDateRange(sl()));

  // Data sources
  sl.registerLazySingleton(() => FirebaseDataSource(
        auth: sl(),
        firestore: sl(),
      ));

  sl.registerFactory(() => OccupancyCubit(
        getCurrentOccupancy: sl(),
        getPeakOccupancyHours: sl(),
        getAverageOccupancyByHour: sl(),
        getOccupancyTrendByDay: sl(),
        compareTimePeriodsOccupancy: sl(),
      ));

  sl.registerFactory(() => GymClassesCubit(
        getAllClasses: sl(),
        getClassById: sl(),
        getClassesByDate: sl(),
        getClassesByTag: sl(),
      ));

  sl.registerFactory(() => ProfileCubit(
        getUserPreferedDays: sl(),
        getUserPreferedWorkout: sl(),
      ));

  //! External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
