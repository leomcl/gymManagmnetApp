import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_optimal_workout_time.dart';
import 'package:test/domain/usecases/optimal_workout/format_optimal_workout_times.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_workout.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_day.dart';
import 'package:test/domain/usecases/optimal_workout/get_class_suggestion.dart';
import 'package:test/domain/usecases/optimal_workout/get_optimal_workout_times.dart';
import 'package:test/domain/entities/gym_class.dart';

part 'optimal_workout_state.dart';

class OptimalWorkoutCubit extends Cubit<OptimalWorkoutState> {
  final GetOptimalWorkoutTimes getOptimalWorkoutTimes;
  final FormatOptimalWorkoutTimes formatOptimalWorkoutTimes;
  final GetCurrentUser getCurrentUser;
  final GetUserPreferedWorkout getUserPreferedWorkout;
  final GetUserPreferedDays getUserPreferedDays;
  final GetClassSuggestion getClassSuggestion;

  OptimalWorkoutCubit({
    required this.getOptimalWorkoutTimes,
    required this.formatOptimalWorkoutTimes,
    required this.getCurrentUser,
    required this.getUserPreferedWorkout,
    required this.getUserPreferedDays,
    required this.getClassSuggestion,
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

      final getUserOptimalWorkoutTime = GetUserOptimalWorkoutTime(
        getUserPreferedDays: getUserPreferedDays,
        getOptimalWorkoutTimes: getOptimalWorkoutTimes,
      );
      final optimalTimes =
          await getUserOptimalWorkoutTime.call(currentUser.uid, limit);

      // Convert List<List<int>> to Map<int, List<int>> for formatOptimalWorkoutTimes
      Map<int, List<int>> optimalTimesMap = {};
      for (int i = 0; i < optimalTimes.length; i++) {
        // Use the preferred day index+1 as the key (1-7 for Monday-Sunday)
        final preferredDay = await getUserPreferedDays(currentUser.uid, limit);
        if (i < preferredDay.length) {
          optimalTimesMap[preferredDay[i]] = optimalTimes[i];
        }
      }

      final formattedResult = formatOptimalWorkoutTimes(optimalTimesMap);
      final preferredWorkoutTypes =
          await getUserPreferedWorkout(currentUser.uid, limit);
      final preferredWorkoutDays =
          await getUserPreferedDays(currentUser.uid, limit);

      // Get class suggestions for this user
      final classSuggestions = await getClassSuggestion(
          currentUser.uid, 5); // Show top 5 suggestions

      emit(OptimalWorkoutLoaded(
        optimalTimes: optimalTimesMap,
        formattedResult: formattedResult,
        preferredWorkoutTypes: preferredWorkoutTypes,
        preferredWorkoutDays: preferredWorkoutDays,
        classSuggestions: classSuggestions,
      ));
    } catch (e) {
      emit(OptimalWorkoutError(e.toString()));
    }
  }
}
