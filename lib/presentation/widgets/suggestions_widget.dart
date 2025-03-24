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
            _buildWeeklyOptimalTimes(context, state.weekOptimalTimes),

            // Today's optimal times
            if (state.todayOptimalTimes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Best times to train today'),
              const SizedBox(height: 8),
              _buildTodayOptimalTimes(
                  context, state.todayOptimalTimes, state.today),
            ],

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

  Widget _buildWeeklyOptimalTimes(
      BuildContext context, Map<int, List<int>> optimalTimes) {
    if (optimalTimes.isEmpty) {
      return const Text(
          'No optimal workout times found based on your preferences.');
    }

    final daysOfWeek = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };

    // Sort by day of week
    final sortedDays = optimalTimes.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedDays.map((day) {
        final hours = optimalTimes[day] ?? [];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                daysOfWeek[day] ?? 'Unknown',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (hours.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('No optimal times found for this day.'),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hours
                      .map((hour) => _buildTimeChip(context, hour))
                      .toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTodayOptimalTimes(
      BuildContext context, List<int> hours, int today) {
    if (hours.isEmpty) {
      return const Text('No optimal training times for today');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hours
          .map((hour) => _buildTimeChip(context, hour, isToday: true))
          .toList(),
    );
  }

  Widget _buildTimeChip(BuildContext context, int hour,
      {bool isToday = false}) {
    final now = DateTime.now();
    final isCurrentHour = now.hour == hour && isToday;
    final isPastHour = now.hour > hour && isToday;

    return Chip(
      backgroundColor: isCurrentHour
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.7)
          : isPastHour
              ? Colors.grey.withOpacity(0.3)
              : Theme.of(context).primaryColor.withOpacity(0.1),
      label: Text(
        _formatHour(hour),
        style: TextStyle(
          color: isCurrentHour
              ? Colors.white
              : isPastHour
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
          fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      avatar: isCurrentHour
          ? Icon(Icons.access_time_filled, size: 16, color: Colors.white)
          : null,
    );
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 $period';
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
