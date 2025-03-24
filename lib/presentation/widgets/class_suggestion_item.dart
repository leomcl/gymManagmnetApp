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
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
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
                    style: theme.textTheme.titleMedium?.copyWith(
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
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Highly Recommended',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
                context, Icons.calendar_today, _getDayName(gymClass.dayOfWeek)),
            const SizedBox(height: 4),
            _buildInfoRow(context, Icons.access_time,
                _formatTimeOfDay(gymClass.timeOfDay)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: gymClass.tags.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.shade100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  labelStyle: theme.textTheme.bodySmall,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
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
    return days[day]; // monday = 0
  }

  String _formatTimeOfDay(int minutesSinceMidnight) {
    final hours = minutesSinceMidnight ~/ 60;
    final minutes = minutesSinceMidnight % 60;

    final time = DateTime(2022, 1, 1, hours, minutes);
    return DateFormat.jm().format(time); // Formats as "8:30 AM"
  }

  Color _getBackgroundColor(BuildContext context, int score) {
    // Return default/transparent for all cases to match class_view.dart
    return Colors.transparent;

    // Alternatively, if you still want subtle color differences but lighter:
    /*
    final theme = Theme.of(context);
    switch (score) {
      case 3:
        return Colors.blue.shade50; // Very light blue
      case 2:
        return Colors.grey.shade50;
      case 1:
        return theme.cardColor; // Default card color
      default:
        return theme.cardColor;
    }
    */
  }
}
