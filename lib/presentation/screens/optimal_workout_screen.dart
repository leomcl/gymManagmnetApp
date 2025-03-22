import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/optimal_workout/optimal_workout_cubit.dart';
import 'package:test/presentation/widgets/loading_indicator.dart';
import 'package:test/presentation/screens/user_preferences_screen.dart';

class OptimalWorkoutScreen extends StatelessWidget {
  const OptimalWorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimal Workout Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserPreferencesScreen(),
                ),
              ).then((_) {
                // Refresh when returning from preferences
                context.read<OptimalWorkoutCubit>().loadOptimalWorkoutTimes();
              });
            },
            tooltip: 'Set workout preferences',
          ),
        ],
      ),
      body: BlocProvider.value(
        value: context.read<OptimalWorkoutCubit>()..loadOptimalWorkoutTimes(),
        child: BlocBuilder<OptimalWorkoutCubit, OptimalWorkoutState>(
          builder: (context, state) {
            if (state is OptimalWorkoutLoading) {
              return const Center(
                child: LoadingIndicator(),
              );
            } else if (state is OptimalWorkoutLoaded) {
              return _buildLoadedState(context, state);
            } else if (state is OptimalWorkoutError) {
              return _buildErrorState(context, state);
            } else {
              return _buildInitialState(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Configure your preferred workout days to see personalized recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserPreferencesScreen(),
                ),
              ).then((_) {
                // Refresh when returning from preferences
                context.read<OptimalWorkoutCubit>().loadOptimalWorkoutTimes();
              });
            },
            child: const Text('Set Workout Preferences'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, OptimalWorkoutLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Times',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on historical gym occupancy data, these are the best times for you to workout with fewer people around.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Text(
            state.formattedResult,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, OptimalWorkoutError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${state.message}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<OptimalWorkoutCubit>().loadOptimalWorkoutTimes();
            },
            child: const Text('Try Again'),
          ),
          const SizedBox(height: 16),
          if (state.message.contains('preferences not found')) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserPreferencesScreen(),
                  ),
                ).then((_) {
                  // Refresh when returning from preferences
                  context.read<OptimalWorkoutCubit>().loadOptimalWorkoutTimes();
                });
              },
              child: const Text('Set Workout Preferences'),
            ),
          ],
        ],
      ),
    );
  }
}
