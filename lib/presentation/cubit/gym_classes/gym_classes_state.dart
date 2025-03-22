import 'package:equatable/equatable.dart';
import '../../../../domain/entities/gym_class.dart';

enum GymClassFilter { all, fullBody, arms, legs, chest, cardio }

class GymClassesState extends Equatable {
  final List<GymClass> classes;
  final bool isLoading;
  final String? error;
  final GymClassFilter filter;
  final DateTime? selectedDate;
  final GymClass? selectedClass;

  const GymClassesState({
    this.classes = const [],
    this.isLoading = false,
    this.error,
    this.filter = GymClassFilter.all,
    this.selectedDate,
    this.selectedClass,
  });

  GymClassesState copyWith({
    List<GymClass>? classes,
    bool? isLoading,
    String? error,
    GymClassFilter? filter,
    DateTime? selectedDate,
    GymClass? selectedClass,
    bool clearSelectedClass = false,
    bool clearError = false,
  }) {
    return GymClassesState(
      classes: classes ?? this.classes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filter: filter ?? this.filter,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedClass:
          clearSelectedClass ? null : (selectedClass ?? this.selectedClass),
    );
  }

  @override
  List<Object?> get props => [
        classes,
        isLoading,
        error,
        filter,
        selectedDate,
        selectedClass,
      ];
}
