import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_cubit.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_state.dart';

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
              'Select Your Workouts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                      context
                          .read<WorkoutSelectionCubit>()
                          .toggleWorkout(entry.key);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
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
