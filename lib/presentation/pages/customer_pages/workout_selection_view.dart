import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';

class WorkoutSelectionPage extends StatefulWidget {
  const WorkoutSelectionPage({super.key});

  @override
  WorkoutSelectionPageState createState() => WorkoutSelectionPageState();
}

class WorkoutSelectionPageState extends State<WorkoutSelectionPage> {
  Widget _buildWorkoutGrid() {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Available Exercises',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3,
                    children: state.selectedWorkouts.entries.map((entry) {
                      return WorkoutButton(
                        label: entry.key,
                        isSelected: entry.value,
                        onSelected: () {
                          context.read<WorkoutCubit>().toggleWorkout(entry.key);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaveButton() {
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.red[400],
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Finish Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 2,
                  ),
                  onPressed:
                      state.isLoading ? null : () => _handleGymExit(context),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Leave Gym',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExitCodeDialog(String exitCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Use this code at the exit gate:'),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  exitCode,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleGymExit(BuildContext context) async {
    final workoutCubit = context.read<WorkoutCubit>();
    await workoutCubit.handleGymExit();

    final state = workoutCubit.state;
    if (state.exitCode != null) {
      if (mounted) {
        _showExitCodeDialog(state.exitCode!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<WorkoutCubit>(),
      child: Scaffold(
        body: Column(
          children: [
            _buildWorkoutGrid(),
            _buildLeaveButton(),
          ],
        ),
      ),
    );
  }
}

class WorkoutButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const WorkoutButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Theme.of(context).primaryColor : Colors.white,
        foregroundColor:
            isSelected ? Colors.white : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onSelected,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
