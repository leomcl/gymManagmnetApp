import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GymStatsView extends StatefulWidget {
  @override
  _GymStatsViewState createState() => _GymStatsViewState();
}

class _GymStatsViewState extends State<GymStatsView> {

  // Function to get the real-time count of people in the gym
  Stream<int> _getRealTimeGymCount() {
    DateTime now = DateTime.now();

    return FirebaseFirestore.instance
        .collection('gymHourlyStats')
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          int totalEntries = 0;
          int totalExits = 0;

          for (var doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data();
            totalEntries += (data['entries'] as num).toInt();
            totalExits += (data['exits'] as num).toInt();
          }

          return totalEntries - totalExits; 
        });
  }

  // Function to fetch the hourly statistics for the current day
  Future<List<Map<String, dynamic>>> _getHourlyStats() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    QuerySnapshot statsSnapshot = await FirebaseFirestore.instance
        .collection('gymHourlyStats')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp')
        .get();

    List<Map<String, dynamic>> hourlyStats = [];

    for (var doc in statsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      hourlyStats.add({
        'hour': doc.id,
        'entries': data['entries'] ?? 0,
        'exits': data['exits'] ?? 0,
      });
    }

    return hourlyStats;
  }

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
              stream: _getRealTimeGymCount(),
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

            const Text(
              'Hourly Stats for Today:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Fetch and display hourly stats for the day
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getHourlyStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<Map<String, dynamic>> hourlyStats = snapshot.data!;

                  return Expanded(
                    child: ListView.builder(
                      itemCount: hourlyStats.length,
                      itemBuilder: (context, index) {
                        final stat = hourlyStats[index];
                        return ListTile(
                          title: Text('Hour: ${stat['hour']}'),
                          subtitle: Text(
                              'Entries: ${stat['entries']}, Exits: ${stat['exits']}'),
                        );
                      },
                    ),
                  );
                } else {
                  return const Text('No data available for today.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
