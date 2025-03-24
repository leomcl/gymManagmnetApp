part of 'suggestions_cubit.dart';

abstract class SuggestionsState extends Equatable {
  const SuggestionsState();

  @override
  List<Object?> get props => [];
}

class SuggestionsInitial extends SuggestionsState {}

class SuggestionsLoading extends SuggestionsState {}

class SuggestionsLoaded extends SuggestionsState {
  final Map<int, List<int>> weekOptimalTimes;
  final List<int> todayOptimalTimes;
  final int today;
  final Map<GymClass, int> classSuggestions;

  const SuggestionsLoaded({
    required this.weekOptimalTimes,
    required this.todayOptimalTimes,
    required this.today,
    required this.classSuggestions,
  });

  @override
  List<Object?> get props => [
        weekOptimalTimes,
        todayOptimalTimes,
        today,
        classSuggestions,
      ];
}

class SuggestionsError extends SuggestionsState {
  final String message;

  const SuggestionsError(this.message);

  @override
  List<Object?> get props => [message];
}
