import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class GymStatsView extends StatefulWidget {
  const GymStatsView({super.key});

  @override
  State<GymStatsView> createState() => _GymStatsViewState();
}

class _GymStatsViewState extends State<GymStatsView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOccupancyCard(),
            const SizedBox(height: 24),
            _buildHourlyAttendanceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOccupancyCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, 
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Current Occupancy',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<int>(
              stream: _getRealTimeGymCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[700]),
                  );
                } else if (snapshot.hasData) {
                  return Row(
                    children: [
                      Text(
                        '${snapshot.data}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'people currently in the gym',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }
                return const Text('No data available');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyAttendanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insert_chart,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Hourly Attendance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    // Placeholder for bar chart - you'll need to implement the actual chart
    // using a charting library like fl_chart
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'Bar Chart Coming Soon',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Real-time count of people in the gym
  Stream<int> _getRealTimeGymCount() {
    // This is a placeholder implementation - replace with your actual Firestore query
    return Stream.periodic(const Duration(seconds: 1), (count) => 15 + (count % 10));
    
    // Real implementation would look like:
    /*
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
    */
  }
} 