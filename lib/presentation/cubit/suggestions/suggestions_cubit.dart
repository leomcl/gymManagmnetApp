import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test/domain/entities/gym_class.dart';
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_optimal_workout_time.dart';
import 'package:test/domain/usecases/optimal_workout/format_optimal_workout_times.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_workout.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_day.dart';
import 'package:test/domain/usecases/optimal_workout/get_class_suggestion.dart';
import 'package:test/domain/usecases/optimal_workout/get_optimal_workout_times.dart';

part 'suggestions_state.dart';

class SuggestionsCubit extends Cubit<SuggestionsState> {
  final GetOptimalWorkoutTimes getOptimalWorkoutTimes;
  final FormatOptimalWorkoutTimes formatOptimalWorkoutTimes;
  final GetCurrentUser getCurrentUser;
  final GetUserPreferedWorkout getUserPreferedWorkout;
  final GetUserPreferedDays getUserPreferedDays;
  final GetClassSuggestion getClassSuggestion;

  SuggestionsCubit({
    required this.getOptimalWorkoutTimes,
    required this.formatOptimalWorkoutTimes,
    required this.getCurrentUser,
    required this.getUserPreferedWorkout,
    required this.getUserPreferedDays,
    required this.getClassSuggestion,
  }) : super(SuggestionsInitial());

  Future<void> loadSuggestions() async {
    emit(SuggestionsLoading());
    const int limit = 3;

    try {
      final currentUser = await getCurrentUser();

      if (currentUser == null) {
        emit(SuggestionsError('User not authenticated'));
        return;
      }

      // Get optimal workout times
      final getUserOptimalWorkoutTime = GetUserOptimalWorkoutTime(
        getUserPreferedDays: getUserPreferedDays,
        getOptimalWorkoutTimes: getOptimalWorkoutTimes,
      );
      final optimalTimes =
          await getUserOptimalWorkoutTime.call(currentUser.uid, limit);

      // Convert List<List<int>> to Map<int, List<int>> for formatOptimalWorkoutTimes
      Map<int, List<int>> optimalTimesMap = {};
      for (int i = 0; i < optimalTimes.length; i++) {
        final preferredDay = await getUserPreferedDays(currentUser.uid, limit);
        if (i < preferredDay.length) {
          optimalTimesMap[preferredDay[i]] = optimalTimes[i];
        }
      }

      final formattedResult = formatOptimalWorkoutTimes(optimalTimesMap);

      // Get today's optimal times
      final today = DateTime.now().weekday;
      final todayOptimalTimes = optimalTimesMap[today] ?? [];
      String todayFormattedTimes = '';

      if (todayOptimalTimes.isNotEmpty) {
        final todayMap = <int, List<int>>{today: todayOptimalTimes};
        todayFormattedTimes = formatOptimalWorkoutTimes(todayMap);
      } else {
        todayFormattedTimes = 'No optimal training times for today';
      }

      // Get class suggestions
      final classSuggestions = await getClassSuggestion(
          currentUser.uid, 3); // Show top 3 suggestions

      emit(SuggestionsLoaded(
        weekOptimalTimes: formattedResult,
        todayOptimalTimes: todayFormattedTimes,
        classSuggestions: classSuggestions,
      ));
    } catch (e) {
      emit(SuggestionsError(e.toString()));
    }
  }
}
