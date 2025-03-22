import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_cubit.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_state.dart';
import 'package:intl/intl.dart';

class WorkoutSelectionWidget extends StatelessWidget {
  const WorkoutSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutSelectionCubit, WorkoutSelectionState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workout Selection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Mode selection buttons
            Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    context,
                    'Solo Workout',
                    state.workoutMode == WorkoutMode.solo,
                    () => context
                        .read<WorkoutSelectionCubit>()
                        .setWorkoutMode(WorkoutMode.solo),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModeButton(
                    context,
                    'Class Workout',
                    state.workoutMode == WorkoutMode.class_,
                    () => context
                        .read<WorkoutSelectionCubit>()
                        .setWorkoutMode(WorkoutMode.class_),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Show appropriate content based on selection
            if (state.workoutMode == WorkoutMode.solo)
              _buildSoloWorkoutSelection(context, state)
            else
              _buildClassSelection(context, state),
          ],
        );
      },
    );
  }

  Widget _buildModeButton(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Theme.of(context).primaryColor : Colors.white,
        foregroundColor:
            isSelected ? Colors.white : Theme.of(context).primaryColor,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSoloWorkoutSelection(
      BuildContext context, WorkoutSelectionState state) {
    return SizedBox(
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
              context.read<WorkoutSelectionCubit>().toggleWorkout(entry.key);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClassSelection(
      BuildContext context, WorkoutSelectionState state) {
    if (state.todayClasses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No classes available today',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        itemCount: state.todayClasses.length,
        itemBuilder: (context, index) {
          final gymClass = state.todayClasses[index];
          final isSelected = state.selectedClass?.classId == gymClass.classId;

          return Card(
            elevation: isSelected ? 2 : 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              onTap: () =>
                  context.read<WorkoutSelectionCubit>().selectClass(gymClass),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.2)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gymClass.className,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black,
                            ),
                          ),
                          Text(
                            DateFormat('h:mm a').format(gymClass.classTime),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
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
