import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_day.dart';
import 'package:test/domain/usecases/optimal_workout/get_user_prefered_workout.dart';
import 'package:test/presentation/cubit/profile/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserPreferedDays getUserPreferedDays;
  final GetUserPreferedWorkout getUserPreferedWorkout;

  ProfileCubit({
    required this.getUserPreferedDays,
    required this.getUserPreferedWorkout,
  }) : super(const ProfileState());

  Future<void> loadUserProfileData(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Get top 3 preferred days and workouts
      final preferredDays = await getUserPreferedDays(userId, 3);
      final preferredWorkouts = await getUserPreferedWorkout(userId, 3);

      emit(state.copyWith(
        isLoading: false,
        preferredDays: preferredDays,
        preferredWorkouts: preferredWorkouts,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
