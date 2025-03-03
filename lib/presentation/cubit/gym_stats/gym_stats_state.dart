import 'package:equatable/equatable.dart';

class GymStatsState extends Equatable {
  final bool isLoading;
  final int? occupancy;
  final String? errorMessage;

  const GymStatsState({
    this.isLoading = false,
    this.occupancy,
    this.errorMessage,
  });

  GymStatsState copyWith({
    bool? isLoading,
    int? occupancy,
    String? errorMessage,
  }) {
    return GymStatsState(
      isLoading: isLoading ?? this.isLoading,
      occupancy: occupancy ?? this.occupancy,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, occupancy, errorMessage];
} 