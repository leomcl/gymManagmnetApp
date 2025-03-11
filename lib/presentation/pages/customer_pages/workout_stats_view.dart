import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout_stats/cubit/workout_stats_cubit.dart';
import 'package:intl/intl.dart';
import 'package:test/di/injection_container.dart' as di;

class WorkoutSelectionPage extends StatefulWidget {
  const WorkoutSelectionPage({super.key});

  @override
  WorkoutSelectionPageState createState() => WorkoutSelectionPageState();
}

class WorkoutSelectionPageState extends State<WorkoutSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<WorkoutStatsCubit>()..loadWorkoutHistory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout History'),
        ),
        body: BlocBuilder<WorkoutStatsCubit, WorkoutStatsState>(
          builder: (context, state) {
            switch (state.status) {
              case WorkoutStatsStatus.initial:
              case WorkoutStatsStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case WorkoutStatsStatus.failure:
                return Center(
                  child: Text('Error: ${state.error ?? "Unknown error"}'),
                );

              case WorkoutStatsStatus.success:
                if (state.workouts.isEmpty) {
                  return const Center(
                    child: Text('No workout history available'),
                  );
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWorkoutStats(state.workouts),
                        const SizedBox(height: 20),
                        const Text(
                          'Recent Workouts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildWorkoutList(state.workouts),
                      ],
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutStats(List<Map<String, dynamic>> workouts) {
    final totalWorkouts = workouts.length;
    final totalMinutes = workouts.fold<int>(
      0,
      (sum, workout) => sum + (workout['duration'] as int),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Workouts', totalWorkouts.toString()),
                _buildStatItem(
                  'Total Time',
                  '${(totalMinutes / 60).toStringAsFixed(1)} hours',
                ),
                _buildStatItem(
                  'Avg. Duration',
                  '${(totalMinutes / totalWorkouts).toStringAsFixed(0)} min',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutList(List<Map<String, dynamic>> workouts) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        final entryTime = workout['entryTime'] as DateTime;
        final duration = workout['duration'] as int;
        final workoutType = workout['workoutType'] as String;

        final workoutTags = workout['workoutTags'] is Map
            ? (workout['workoutTags'] as Map)
                .entries
                .where((e) => e.value == true)
                .map((e) => e.key.toString())
                .toList()
            : <String>[];

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text(
              workoutType,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM d, y - h:mm a').format(entryTime)),
                Text('Duration: $duration minutes'),
                if (workoutTags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: workoutTags
                        .map((tag) => Chip(
                              label: Text(tag),
                              labelStyle: const TextStyle(fontSize: 12),
                            ))
                        .toList(),
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
