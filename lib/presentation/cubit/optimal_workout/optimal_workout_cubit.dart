import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:test/domain/usecases/optimal_workout/get_optimal_workout_times.dart';
import 'package:test/domain/usecases/optimal_workout/format_optimal_workout_times.dart';

part 'optimal_workout_state.dart';

class OptimalWorkoutCubit extends Cubit<OptimalWorkoutState> {
  final GetOptimalWorkoutTimes getOptimalWorkoutTimes;
  final FormatOptimalWorkoutTimes formatOptimalWorkoutTimes;
  final GetCurrentUser getCurrentUser;

  OptimalWorkoutCubit({
    required this.getOptimalWorkoutTimes,
    required this.formatOptimalWorkoutTimes,
    required this.getCurrentUser,
  }) : super(OptimalWorkoutInitial());

  Future<void> loadOptimalWorkoutTimes() async {
    emit(OptimalWorkoutLoading());

    try {
      final currentUser = await getCurrentUser();

      if (currentUser == null) {
        emit(OptimalWorkoutError('User not authenticated'));
        return;
      }

      final optimalTimes = await getOptimalWorkoutTimes(currentUser.uid);
      final formattedResult = formatOptimalWorkoutTimes(optimalTimes);

      emit(OptimalWorkoutLoaded(
        optimalTimes: optimalTimes,
        formattedResult: formattedResult,
      ));
    } catch (e) {
      emit(OptimalWorkoutError(e.toString()));
    }
  }
}
