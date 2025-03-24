import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/suggestions/suggestions_cubit.dart';
import 'package:test/presentation/widgets/loading_indicator.dart';
import 'package:test/presentation/widgets/class_suggestion_item.dart';

class SuggestionsWidget extends StatelessWidget {
  const SuggestionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<SuggestionsCubit>()..loadSuggestions(),
      child: BlocBuilder<SuggestionsCubit, SuggestionsState>(
        builder: (context, state) {
          if (state is SuggestionsLoading) {
            return _buildLoadingState();
          } else if (state is SuggestionsLoaded) {
            return _buildLoadedState(context, state);
          } else if (state is SuggestionsError) {
            return _buildErrorState(context, state);
          } else {
            return _buildInitialState(context);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: LoadingIndicator(),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Workout Suggestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure your workout preferences to see personalized recommendations',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<SuggestionsCubit>().loadSuggestions();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Refresh Suggestions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, SuggestionsLoaded state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Your Workout Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Class suggestions
            _buildSectionHeader(context, 'Classes for you this week'),
            const SizedBox(height: 8),
            if (state.classSuggestions.isEmpty)
              const Text('No class suggestions found.')
            else
              Column(
                children: state.classSuggestions.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ClassSuggestionItem(
                      gymClass: entry.key,
                      score: entry.value,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Weekly optimal times
            _buildSectionHeader(context, 'Optimal training times this week'),
            const SizedBox(height: 8),
            Text(
              state.weekOptimalTimes,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  context.read<SuggestionsCubit>().loadSuggestions();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Refresh'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Icon(
          _getIconForTitle(title),
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  IconData _getIconForTitle(String title) {
    if (title.contains('Classes')) {
      return Icons.fitness_center;
    } else if (title.contains('week')) {
      return Icons.calendar_month;
    } else {
      return Icons.schedule;
    }
  }

  Widget _buildErrorState(BuildContext context, SuggestionsError state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Error: ${state.message}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<SuggestionsCubit>().loadSuggestions();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
