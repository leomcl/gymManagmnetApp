import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';
import 'package:test/presentation/widgets/workout_button_widget.dart';

class WorkoutGridWidget extends StatelessWidget {
  const WorkoutGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutCubit, WorkoutState>(
      builder: (context, state) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3,
              children: state.selectedWorkouts.entries.map((entry) {
                return WorkoutButtonWidget(
                  label: entry.key,
                  isSelected: entry.value,
                  onSelected: () {
                    context.read<WorkoutCubit>().toggleWorkout(entry.key);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
} 