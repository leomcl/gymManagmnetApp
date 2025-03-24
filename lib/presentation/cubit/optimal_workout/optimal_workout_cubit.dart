import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:test/domain/usecases/optimal_workout/get_optimal_workout_times.dart';
import 'package:test/domain/usecases/optimal_workout/format_optimal_workout_times.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_workout.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_day.dart';

part 'optimal_workout_state.dart';

class OptimalWorkoutCubit extends Cubit<OptimalWorkoutState> {
  final GetOptimalWorkoutTimes getOptimalWorkoutTimes;
  final FormatOptimalWorkoutTimes formatOptimalWorkoutTimes;
  final GetCurrentUser getCurrentUser;
  final GetUserPreferedWorkout getUserPreferedWorkout;
  final GetUserPreferedDays getUserPreferedDays;

  OptimalWorkoutCubit({
    required this.getOptimalWorkoutTimes,
    required this.formatOptimalWorkoutTimes,
    required this.getCurrentUser,
    required this.getUserPreferedWorkout,
    required this.getUserPreferedDays,
  }) : super(OptimalWorkoutInitial());

  Future<void> loadOptimalWorkoutTimes() async {
    emit(OptimalWorkoutLoading());
    const int limit = 3;

    try {
      final currentUser = await getCurrentUser();

      if (currentUser == null) {
        emit(OptimalWorkoutError('User not authenticated'));
        return;
      }

      final optimalTimes = await getOptimalWorkoutTimes(currentUser.uid);
      final formattedResult = formatOptimalWorkoutTimes(optimalTimes);
      final preferredWorkoutTypes =
          await getUserPreferedWorkout(currentUser.uid, limit);
      final preferredWorkoutDays =
          await getUserPreferedDays(currentUser.uid, limit);

      emit(OptimalWorkoutLoaded(
        optimalTimes: optimalTimes,
        formattedResult: formattedResult,
        preferredWorkoutTypes: preferredWorkoutTypes,
        preferredWorkoutDays: preferredWorkoutDays,
      ));
    } catch (e) {
      emit(OptimalWorkoutError(e.toString()));
    }
  }
}
