import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout_stats/cubit/workout_stats_cubit.dart';
import 'package:intl/intl.dart';
import 'package:test/di/injection_container.dart' as di;
import 'package:test/domain/entities/workout.dart';

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

  Widget _buildWorkoutStats(List<Workout> workouts) {
    final totalWorkouts = workouts.length;
    final totalMinutes = workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.duration,
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

  Widget _buildWorkoutList(List<Workout> workouts) {
    return Column(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            return _buildWorkoutItem(workouts[index]);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: TextButton(
              onPressed: () {
                // Navigate to detailed workout history
              },
              child: const Text('View Complete History'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutItem(Workout workout) {
    final entryTime = workout.entryTime;
    final duration = workout.duration;
    final workoutType = workout.workoutType;
    final now = DateTime.now();
    final difference = now.difference(entryTime);

    // Format relative time
    String relativeTime;
    if (difference.inDays == 0) {
      relativeTime = 'Today';
    } else if (difference.inDays == 1) {
      relativeTime = 'Yesterday';
    } else if (difference.inDays < 7) {
      relativeTime = '${difference.inDays} days ago';
    } else {
      relativeTime = DateFormat('MMM d').format(entryTime);
    }

    // Get icon based on workout type
    IconData workoutIcon;
    Color iconColor;
    Color bgColor;

    switch (workoutType.toLowerCase()) {
      case 'cardio':
        workoutIcon = Icons.directions_run;
        iconColor = Colors.green;
        bgColor = Colors.green[100]!;
        break;
      case 'running':
      case 'jogging':
        workoutIcon = Icons.directions_run;
        iconColor = Colors.green;
        bgColor = Colors.green[100]!;
        break;
      case 'strength':
        workoutIcon = Icons.fitness_center;
        iconColor = Colors.blue;
        bgColor = Colors.blue[100]!;
        break;
      case 'weight training':
        workoutIcon = Icons.fitness_center;
        iconColor = Colors.blue;
        bgColor = Colors.blue[100]!;
        break;
      case 'bodybuilding':
        workoutIcon = Icons.fitness_center;
        iconColor = Colors.blue;
        bgColor = Colors.blue[100]!;
        break;
      case 'yoga':
      case 'stretching':
      case 'flexibility':
        workoutIcon = Icons.self_improvement;
        iconColor = Colors.purple;
        bgColor = Colors.purple[100]!;
        break;
      case 'swimming':
        workoutIcon = Icons.pool;
        iconColor = Colors.cyan;
        bgColor = Colors.cyan[100]!;
        break;
      case 'cycling':
      case 'biking':
        workoutIcon = Icons.directions_bike;
        iconColor = Colors.orange;
        bgColor = Colors.orange[100]!;
        break;
      default:
        workoutIcon = Icons.sports;
        iconColor = Colors.indigo;
        bgColor = Colors.indigo[100]!;
    }

    // Get workout tags
    final workoutTags = workout.workoutTags;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // Navigate to workout details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: bgColor,
                        child: Icon(workoutIcon, color: iconColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        workoutType,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$duration min',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                relativeTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (workoutTags.isNotEmpty) const SizedBox(height: 8),
              if (workoutTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: workoutTags
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.blue.shade100,
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
