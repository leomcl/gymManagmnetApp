import 'package:equatable/equatable.dart';

class GymStatsState extends Equatable {
  final bool isLoading;
  final int? occupancy;
  final Map<int, int>? hourlyAttendance;
  final String? errorMessage;

  const GymStatsState({
    this.isLoading = false,
    this.occupancy,
    this.hourlyAttendance,
    this.errorMessage,
  });

  GymStatsState copyWith({
    bool? isLoading,
    int? occupancy,
    Map<int, int>? hourlyAttendance,
    String? errorMessage,
  }) {
    return GymStatsState(
      isLoading: isLoading ?? this.isLoading,
      occupancy: occupancy ?? this.occupancy,
      hourlyAttendance: hourlyAttendance ?? this.hourlyAttendance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, occupancy, hourlyAttendance, errorMessage];
} 