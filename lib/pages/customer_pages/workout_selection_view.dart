import 'package:flutter/material.dart';

class WorkoutSelectionPage extends StatefulWidget {
  const WorkoutSelectionPage({super.key});

  @override
  WorkoutSelectionPageState createState() => WorkoutSelectionPageState();
}

class WorkoutSelectionPageState extends State<WorkoutSelectionPage> {
  // Tracks the selected status of each workout
  final Map<String, bool> _selectedWorkouts = {
    'Cardio': false,
    'Legs': false,
    'Chest': false,
    'Arms': false,
    'Full Body': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                "Customer's Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Duration: 00:00',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            child: Text(
              'Select workout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                minimumSize: Size(double.infinity, 48),
              ),
              onPressed: () {
                // Leave gym button functionality
              },
              child: Text('Leave Gym'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWorkoutSelection(String workout) {
    setState(() {
      _selectedWorkouts[workout] = !_selectedWorkouts[workout]!;
    });
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
        backgroundColor: isSelected ? const Color.fromARGB(255, 161, 76, 175) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.purple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        side: BorderSide(color: Colors.purple),
        elevation: 0,
      ),
      onPressed: onSelected,
      child: Text(label),
    );
  }
}
