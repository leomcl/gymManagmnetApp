import 'package:flutter/material.dart';
import 'package:test/utils/access_code_generator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSelectionPage extends StatefulWidget {
  const WorkoutSelectionPage({super.key});

  @override
  WorkoutSelectionPageState createState() => WorkoutSelectionPageState();
}

class WorkoutSelectionPageState extends State<WorkoutSelectionPage> {
  // Constants
  static const Map<String, bool> initialWorkouts = {
    'Cardio': false,
    'Legs': false,
    'Chest': false,
    'Arms': false,
    'Full Body': false,
  };

  // State
  final Map<String, bool> _selectedWorkouts = Map.from(initialWorkouts);

  // Firebase Methods
  Future<void> _recordGymUsage() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final entryTime = DateTime.now();
    final duration = entryTime.difference(entryTime).inMinutes;

    await FirebaseFirestore.instance
        .collection('gymUsageHistory')
        .doc('${userId}_${entryTime.toIso8601String()}')
        .set({
      'userId': userId,
      'entryTime': entryTime,
      'exitTime': entryTime,
      'duration': duration,
      'workoutTags': _selectedWorkouts,
      'workoutType': 'regular',
    });
  }

  Future<void> _handleGymExit() async {
    try {
      await _recordGymUsage();
      
      final exitCode = await AccessCodeGenerator.generateAndSaveCode(
        userId: FirebaseAuth.instance.currentUser!.uid,
        isEntry: false,
      );

      if (mounted) {
        _showExitCodeDialog(exitCode);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error generating exit code: $e');
      }
    }
  }

  // UI Helper Methods
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _toggleWorkoutSelection(String workout) {
    setState(() {
      _selectedWorkouts[workout] = !_selectedWorkouts[workout]!;
    });
  }

  // UI Building Methods
  Widget _buildTimer() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          const Text(
            'Duration: 00:00',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutGrid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: _selectedWorkouts.keys.map((workout) {
            return WorkoutButton(
              label: workout,
              isSelected: _selectedWorkouts[workout] ?? false,
              onSelected: () => _toggleWorkoutSelection(workout),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLeaveButton() {
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
        onPressed: _handleGymExit,
        child: const Text(
          'Leave Gym',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Customer's Name",
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
          _buildTimer(),
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
          _buildWorkoutGrid(),
          _buildLeaveButton(),
        ],
      ),
    );
  }
}

// Keep WorkoutButton as is
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
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2,
        ),
        elevation: isSelected ? 4 : 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onSelected,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
