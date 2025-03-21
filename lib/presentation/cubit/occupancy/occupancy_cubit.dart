import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/occupancy/get_current_occupancy.dart';
import '../../../domain/usecases/occupancy/get_peak_occupancy_hours.dart';
import '../../../domain/usecases/occupancy/get_average_occupancy_by_hour.dart';
import '../../../domain/usecases/occupancy/get_occupancy_trend_by_day.dart';
import '../../../domain/usecases/occupancy/compare_time_periods_occupancy.dart';
import 'occupancy_state.dart';
import '../../../domain/entities/occupancy.dart';

class OccupancyCubit extends Cubit<OccupancyState> {
  final GetCurrentOccupancy getCurrentOccupancy;
  final GetPeakOccupancyHours getPeakOccupancyHours;
  final GetAverageOccupancyByHour getAverageOccupancyByHour;
  final GetOccupancyTrendByDay getOccupancyTrendByDay;
  final CompareTimePeriodsOccupancy compareTimePeriodsOccupancy;

  OccupancyCubit({
    required this.getCurrentOccupancy,
    required this.getPeakOccupancyHours,
    required this.getAverageOccupancyByHour,
    required this.getOccupancyTrendByDay,
    required this.compareTimePeriodsOccupancy,
  }) : super(OccupancyState.initial());

  Future<void> loadCurrentOccupancy() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // If viewing historical data (not today), use the selected date
      final selectedDate = state.selectedDate;
      final now = DateTime.now();
      final isToday = selectedDate.year == now.year &&
          selectedDate.month == now.month &&
          selectedDate.day == now.day;

      // For current day, get real-time occupancy
      final currentCount = await getCurrentOccupancy.execute();

      // If not today and count is 0, likely no data for this date
      if (!isToday && currentCount == 0) {
        emit(state.copyWith(
          currentOccupancy: null,
          isLoading: false,
        ));
        return;
      }

      // Get the date to use for display
      final dateToUse = isToday ? now : selectedDate;
      final currentHour =
          isToday ? now.hour : 18; // Use 6PM as default for historical data

      // Create an Occupancy object with the count
      final occupancy = Occupancy(
        entries: currentCount,
        exits: 0,
        lastUpdated: dateToUse,
        hourId:
            '${dateToUse.year}-${dateToUse.month}-${dateToUse.day}-$currentHour',
      );

      emit(state.copyWith(
        currentOccupancy: occupancy,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadPeakHours() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final peaks = await getPeakOccupancyHours(state.selectedDate);

      // Check if any meaningful data exists
      final hasMeaningfulData = peaks.any((peak) => peak.currentOccupancy > 0);

      emit(state.copyWith(
        peakHours: hasMeaningfulData ? peaks : [],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> loadAverageByHour() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final selectedDate = state.selectedDate;
      DateTime startDate;
      DateTime endDate;

      switch (state.timePeriod) {
        case TimePeriod.daily:
          // Set start date to beginning of selected day
          startDate =
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
          endDate = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, 23, 59, 59);
          break;
        case TimePeriod.weekly:
          // Set date range to 7 days ending on selected date
          endDate = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, 23, 59, 59);
          startDate = endDate.subtract(const Duration(days: 6));
          break;
        case TimePeriod.monthly:
          // Set date range to the month containing the selected date
          startDate = DateTime(selectedDate.year, selectedDate.month, 1);
          final nextMonth = selectedDate.month == 12
              ? DateTime(selectedDate.year + 1, 1, 1)
              : DateTime(selectedDate.year, selectedDate.month + 1, 1);
          endDate = nextMonth.subtract(const Duration(days: 1));
          break;
      }

      final averages = await getAverageOccupancyByHour(startDate, endDate);

      // Check if there's any meaningful data (non-zero averages)
      final hasMeaningfulData = averages.values.any((value) => value > 0);

      emit(state.copyWith(
        averageByHour: hasMeaningfulData ? averages : {},
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void changeSelectedDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
    loadCurrentOccupancy();
    loadPeakHours();
    loadAverageByHour();
  }

  void changeTimePeriod(TimePeriod period) {
    emit(state.copyWith(timePeriod: period));
    loadAverageByHour();
  }

  Future<void> loadAllData() async {
    emit(state.copyWith(isLoading: true));
    try {
      await loadCurrentOccupancy();
      await loadPeakHours();
      await loadAverageByHour();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  String getBusiestHourString() {
    if (state.peakHours.isEmpty) return 'N/A';

    final peakHour = state.peakHours.first;
    final hour = peakHour.hour;
    final formattedHour = hour > 12 ? '${hour - 12} PM' : '$hour AM';
    return '$formattedHour (${peakHour.currentOccupancy} people)';
  }

  int getCurrentCapacityPercentage() {
    if (state.currentOccupancy == null) return 0;

    // Return 0 if occupancy is 0 (likely no data)
    if (state.currentOccupancy!.currentOccupancy <= 0) return 0;

    // Assuming max capacity of 100 for demonstration
    // This could be a configurable parameter or derived from the data
    const maxCapacity = 100;
    return ((state.currentOccupancy!.currentOccupancy / maxCapacity) * 100)
        .round();
  }
}
