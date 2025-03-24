import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final List<int> preferredDays;
  final List<String> preferredWorkouts;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.preferredDays = const [],
    this.preferredWorkouts = const [],
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    List<int>? preferredDays,
    List<String>? preferredWorkouts,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      preferredDays: preferredDays ?? this.preferredDays,
      preferredWorkouts: preferredWorkouts ?? this.preferredWorkouts,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, preferredDays, preferredWorkouts, error];
}
