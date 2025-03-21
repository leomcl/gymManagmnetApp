import 'package:equatable/equatable.dart';
import '../../../domain/entities/occupancy.dart';

enum TimePeriod { daily, weekly, monthly }

class OccupancyState extends Equatable {
  final Occupancy? currentOccupancy;
  final List<Occupancy> peakHours;
  final Map<int, double> averageByHour;
  final bool isLoading;
  final String? error;
  final TimePeriod timePeriod;
  final DateTime selectedDate;

  const OccupancyState({
    this.currentOccupancy,
    this.peakHours = const [],
    this.averageByHour = const {},
    this.isLoading = false,
    this.error,
    this.timePeriod = TimePeriod.daily,
    required this.selectedDate,
  });

  factory OccupancyState.initial() {
    return OccupancyState(
      selectedDate: DateTime.now(),
    );
  }

  OccupancyState copyWith({
    Occupancy? currentOccupancy,
    List<Occupancy>? peakHours,
    Map<int, double>? averageByHour,
    bool? isLoading,
    String? error,
    TimePeriod? timePeriod,
    DateTime? selectedDate,
  }) {
    return OccupancyState(
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      peakHours: peakHours ?? this.peakHours,
      averageByHour: averageByHour ?? this.averageByHour,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      timePeriod: timePeriod ?? this.timePeriod,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [
        currentOccupancy,
        peakHours,
        averageByHour,
        isLoading,
        error,
        timePeriod,
        selectedDate,
      ];
}
