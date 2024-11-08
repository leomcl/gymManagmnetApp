import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gym_bar_chart.dart';

class GymStatsView extends StatefulWidget {
  const GymStatsView({Key? key}) : super(key: key);

  @override
  _GymStatsViewState createState() => _GymStatsViewState();
}

class _GymStatsViewState extends State<GymStatsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Stats'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current People in the Gym:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Real-time display of the number of people in the gym
            StreamBuilder<int>(
              stream: _getRealTimeGymCountFromFirestore(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(
                    '${snapshot.data} people are currently in the gym',
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                  );
                } else {
                  return const Text('No data available');
                }
              },
            ),

            const SizedBox(height: 30),

            // Display the hourly entries chart
            const Text(
              'Hourly Gym Attendance:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Expanded(
              child: HourlyEntriesChart(),
            ),
          ],
        ),
      ),
    );
  }

  // Real-time count of people in the gym
  Stream<int> _getRealTimeGymCountFromFirestore() {
    return FirebaseFirestore.instance
        .collection('gymHourlyStats')
        .snapshots()
        .map((snapshot) {
      int totalCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        int entries = data['entries'] ?? 0;
        int exits = data['exits'] ?? 0;
        totalCount += entries - exits;
      }
      return totalCount;
    });
  }
}
