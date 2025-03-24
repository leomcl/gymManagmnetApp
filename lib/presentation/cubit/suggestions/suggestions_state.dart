part of 'suggestions_cubit.dart';

abstract class SuggestionsState extends Equatable {
  const SuggestionsState();

  @override
  List<Object?> get props => [];
}

class SuggestionsInitial extends SuggestionsState {}

class SuggestionsLoading extends SuggestionsState {}

class SuggestionsLoaded extends SuggestionsState {
  final String weekOptimalTimes;
  final String todayOptimalTimes;
  final Map<GymClass, int> classSuggestions;

  const SuggestionsLoaded({
    required this.weekOptimalTimes,
    required this.todayOptimalTimes,
    required this.classSuggestions,
  });

  @override
  List<Object?> get props => [
        weekOptimalTimes,
        todayOptimalTimes,
        classSuggestions,
      ];
}

class SuggestionsError extends SuggestionsState {
  final String message;

  const SuggestionsError(this.message);

  @override
  List<Object?> get props => [message];
}
