import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/occupancy/occupancy_cubit.dart';
import '../../cubit/occupancy/occupancy_state.dart';

class GymStatsView extends StatelessWidget {
  const GymStatsView({super.key});

@override
  Widget build(BuildContext context) {
    return BlocBuilder<OccupancyCubit, OccupancyState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gym Usage',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildOccupancyTable(context, state),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDateSelector(context, state),
                                const SizedBox(height: 16),
                                _buildTimePeriodToggle(context, state),
                                const SizedBox(height: 24),
                                _buildCurrentOccupancy(context, state),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: _buildPeakHoursCard(context, state),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCurrentOccupancy(BuildContext context, OccupancyState state) {
    final percentage =
        context.read<OccupancyCubit>().getCurrentCapacityPercentage();
    final currentCount = state.currentOccupancy?.currentOccupancy ?? 0;
    final hasData = state.currentOccupancy != null && currentCount > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Occupancy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            hasData
                ? Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 20,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 80
                                ? Colors.red
                                : percentage > 50
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '$currentCount people\n$percentage% full',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('No data available')),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodToggle(BuildContext context, OccupancyState state) {
    return SegmentedButton<TimePeriod>(
      segments: const [
        ButtonSegment<TimePeriod>(
          value: TimePeriod.daily,
          label: Text('Daily'),
        ),
        ButtonSegment<TimePeriod>(
          value: TimePeriod.weekly,
          label: Text('Weekly'),
        ),
        ButtonSegment<TimePeriod>(
          value: TimePeriod.monthly,
          label: Text('Monthly'),
        ),
      ],
      selected: {state.timePeriod},
      onSelectionChanged: (Set<TimePeriod> selection) {
        if (selection.isNotEmpty) {
          context.read<OccupancyCubit>().changeTimePeriod(selection.first);
        }
      },
    );
  }

  Widget _buildDateSelector(BuildContext context, OccupancyState state) {
    return Row(
      children: [
        Text(
          'Date: ${DateFormat('MMM dd, yyyy').format(state.selectedDate)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: state.selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != state.selectedDate) {
              context.read<OccupancyCubit>().changeSelectedDate(picked);
            }
          },
        ),
      ],
    );
  }

  Widget _buildOccupancyTable(BuildContext context, OccupancyState state) {
    if (state.averageByHour.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Average Occupancy by Hour',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: Center(child: Text('No data available')),
              ),
            ],
          ),
        ),
      );
    }

    final sortedEntries = state.averageByHour.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average Occupancy by Hour',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Hour')),
                      DataColumn(label: Text('Average Occupancy')),
                    ],
                    rows: sortedEntries.map((entry) {
                      final hour = entry.key;
                      final occupancy = entry.value.toInt();
                      final widthFactor = (occupancy / 100).clamp(0.0, 1.0);

                      return DataRow(cells: [
                        DataCell(Text(hour > 12
                            ? '${hour - 12} PM'
                            : hour == 12
                                ? '12 PM'
                                : hour == 0
                                    ? '12 AM'
                                    : '$hour AM')),
                        DataCell(Row(
                          children: [
                            Container(
                              width: 150,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: widthFactor,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('$occupancy',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakHoursCard(BuildContext context, OccupancyState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peak Hours',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            state.peakHours.isEmpty
                ? const Text('No data available')
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: state.peakHours.map((peak) {
                          final hour = peak.hour;
                          final formattedHour = hour > 12
                              ? '${hour - 12} PM'
                              : hour == 12
                                  ? '12 PM'
                                  : hour == 0
                                      ? '12 AM'
                                      : '$hour AM';

                          return ListTile(
                            leading: const Icon(Icons.people),
                            title: Text(
                                '$formattedHour (${peak.currentOccupancy} people)'),
                            subtitle: Text(
                              DateFormat('EEEE, MMM d').format(peak.date),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
