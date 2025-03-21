import 'package:equatable/equatable.dart';

class WorkoutState extends Equatable {
  final Map<String, bool> selectedWorkouts;
  final String? exitCode;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? startTime;
  final String? entryCode;
  final bool isInGym;

  const WorkoutState({
    required this.selectedWorkouts,
    this.exitCode,
    this.isLoading = false,
    this.errorMessage,
    this.startTime,
    this.entryCode,
    this.isInGym = false,
  });

  factory WorkoutState.initial() {
    return const WorkoutState(
      selectedWorkouts: {
        'Cardio': false,
        'Legs': false,
        'Chest': false,
        'Arms': false,
        'Full Body': false,
      },
      startTime: null,
      isInGym: false,
    );
  }

  WorkoutState copyWith({
    Map<String, bool>? selectedWorkouts,
    String? exitCode,
    bool? isLoading,
    String? errorMessage,
    DateTime? startTime,
    String? entryCode,
    bool? isInGym,
  }) {
    return WorkoutState(
      selectedWorkouts: selectedWorkouts ?? this.selectedWorkouts,
      exitCode: exitCode ?? this.exitCode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      entryCode: entryCode ?? this.entryCode,
      isInGym: isInGym ?? this.isInGym,
    );
  }

  @override
  List<Object?> get props => [
        selectedWorkouts,
        exitCode,
        isLoading,
        errorMessage,
        startTime,
        entryCode,
        isInGym,
      ];
}
