// hourly_entries_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Function to get cumulative people count per hour (entries - exits)
Future<Map<int, int>> getHourlyEntriesForToday() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  try {
    final CollectionReference statsCollection = firestore.collection('gymHourlyStats');

    QuerySnapshot snapshot = await statsCollection
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: currentDate)
        .where(FieldPath.documentId, isLessThan: '$currentDate\uFFFF')
        .get();

    Map<int, int> hourlyPeopleCount = {for (int i = 0; i < 24; i++) i: 0};
    int cumulativeCount = 0; // Tracks rolling count of people present

    for (QueryDocumentSnapshot doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String docId = doc.id;
      final int hour = int.parse(docId.split('-')[3]);
      final int entries = (data['entries'] ?? 0) as int;
      final int exits = (data['exits'] ?? 0) as int;

      final int netChange = entries - exits;
      cumulativeCount += netChange;
      hourlyPeopleCount[hour] = cumulativeCount;
    }

    for (int i = 1; i < 24; i++) {
      if (hourlyPeopleCount[i] == 0) {
        hourlyPeopleCount[i] = hourlyPeopleCount[i - 1] ?? 0;
      }
    }

    return hourlyPeopleCount;
  } catch (e) {
    print('Error getting hourly entries: $e');
    return {};
  }
}

// Widget to display the chart
class HourlyEntriesChart extends StatelessWidget {
  const HourlyEntriesChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, int>>(
      future: getHourlyEntriesForToday(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final hourlyEntries = snapshot.data!;
          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: hourlyEntries.values.reduce((a, b) => a > b ? a : b).toDouble() + 5,
              barGroups: hourlyEntries.entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: Colors.blue,
                      width: 15,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(value.toInt().toString());
                    },
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
