import 'package:flutter/material.dart';
import 'package:test/presentation/widgets/workout_timer_widget.dart';
import 'package:test/presentation/widgets/workout_grid_widget.dart';
import 'package:test/presentation/widgets/exit_button_widget.dart';

class WorkoutSelectionPage extends StatefulWidget {
  const WorkoutSelectionPage({super.key});

  @override
  WorkoutSelectionPageState createState() => WorkoutSelectionPageState();
}

class WorkoutSelectionPageState extends State<WorkoutSelectionPage> {
  void _showExitCodeDialog(String exitCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Code'),
          content: Text('Your exit code is: $exitCode'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Today's Workout",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          const Center(child: WorkoutTimerWidget()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Select Your Workout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const WorkoutGridWidget(),
          ExitButtonWidget(
            onExitCodeGenerated: _showExitCodeDialog,
          ),
        ],
      ),
    );
  }
} 