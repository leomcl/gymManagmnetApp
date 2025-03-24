import 'package:flutter/material.dart';
import 'package:test/domain/entities/gym_class.dart';
import 'package:intl/intl.dart';

class ClassSuggestionItem extends StatelessWidget {
  final GymClass gymClass;
  final int score;

  const ClassSuggestionItem({
    Key? key,
    required this.gymClass,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: _getBackgroundColor(score),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gymClass.className,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (score == 3)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Highly Recommended',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.calendar_today, _getDayName(gymClass.dayOfWeek)),
            const SizedBox(height: 4),
            _buildInfoRow(
                Icons.access_time, _formatTimeOfDay(gymClass.timeOfDay)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: gymClass.tags.keys.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Color _getBackgroundColor(int score) {
    switch (score) {
      case 3:
        return Colors.green.withOpacity(0.15);
      case 2:
        return Colors.blue.withOpacity(0.1);
      case 1:
        return Colors.grey.withOpacity(0.1);
      default:
        return Colors.transparent;
    }
  }

  String _getDayName(int day) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[day]; // monday = 0, sunday = 6
  }

  String _formatTimeOfDay(int minutesSinceMidnight) {
    final hours = minutesSinceMidnight ~/ 60;
    final minutes = minutesSinceMidnight % 60;

    final time = DateTime(2022, 1, 1, hours, minutes);
    return DateFormat.jm().format(time); // Formats as "8:30 AM"
  }
}
