import 'package:flutter/material.dart';

class HourlyEntriesChart extends StatelessWidget {
  const HourlyEntriesChart({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for the real chart implementation
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'Hourly Attendance Chart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Coming soon with real data',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
} 