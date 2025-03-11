import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'workout_stats_state.dart';

class WorkoutStatsCubit extends Cubit<WorkoutStatsState> {
  WorkoutStatsCubit() : super(WorkoutStatsInitial());
}
