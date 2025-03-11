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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < workouts.length; index++) ...[
          _buildWorkoutItem(workouts[index]),
          if (index < workouts.length - 1) const Divider(),
        ],
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              // Navigate to detailed workout history
            },
            child: const Text('View Complete History'),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutItem(Map<String, dynamic> workout) {
    final entryTime = workout['entryTime'] as DateTime;
    final duration = workout['duration'] as int;
    final workoutType = workout['workoutType'] as String;
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
    final workoutTags = workout['workoutTags'] is Map
        ? (workout['workoutTags'] as Map)
            .entries
            .where((e) => e.value == true)
            .map((e) => e.key.toString())
            .toList()
        : <String>[];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: Icon(workoutIcon, color: iconColor),
      ),
      title: Text(
        workoutType,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$relativeTime · $duration min'),
          if (workoutTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Wrap(
                spacing: 4,
                children: workoutTags
                    .map((tag) => Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 10),
                          padding: const EdgeInsets.all(0),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to workout details
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      isThreeLine: workoutTags.isNotEmpty,
    );
  }
}
