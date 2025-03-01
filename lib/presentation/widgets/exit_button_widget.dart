import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/repositories/auth_repository.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';

class ExitButtonWidget extends StatelessWidget {
  final Function(String) onExitCodeGenerated;
  
  const ExitButtonWidget({
    super.key, 
    required this.onExitCodeGenerated,
  });

  Future<void> _handleGymExit(BuildContext context) async {
    final userId = context.read<AuthRepository>().currentUser?.uid;
    
    if (userId != null) {
      // First save workout data
      context.read<WorkoutCubit>().saveWorkout(userId);
      
      // Then generate exit code
      context.read<WorkoutCubit>().generateExitCode(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listener: (context, state) {
        if (state.exitCode != null) {
          onExitCodeGenerated(state.exitCode!);
        }
        
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 48),
              elevation: 3,
            ),
            onPressed: state.isLoading 
                ? null 
                : () => _handleGymExit(context),
            child: state.isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Leave Gym',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
} 