import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/occupancy/occupancy_cubit.dart';
import '../../cubit/occupancy/occupancy_state.dart';

class GymStatsView extends StatelessWidget {
  const GymStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh occupancy data every time the view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OccupancyCubit>().loadCurrentOccupancy();
    });

    return BlocBuilder<OccupancyCubit, OccupancyState>(
      builder: (context, state) {
        return state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: const Text('Gym Stats'),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: state.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null &&
                                picked != state.selectedDate) {
                              context
                                  .read<OccupancyCubit>()
                                  .changeSelectedDate(picked);
                            }
                          },
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDateDisplay(context, state),
                            const SizedBox(height: 16),
                            _buildTimePeriodToggle(context, state),
                            const SizedBox(height: 16),
                            _buildCurrentOccupancy(context, state),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Average Occupancy',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: _buildOccupancyList(context, state),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Peak Hours',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: _buildPeakHoursList(context, state),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 24.0),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildDateDisplay(BuildContext context, OccupancyState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          DateFormat('EEEE, MMMM dd, yyyy').format(state.selectedDate),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildCurrentOccupancy(BuildContext context, OccupancyState state) {
    final percentage =
        context.read<OccupancyCubit>().getCurrentCapacityPercentage();
    final currentCount = state.currentOccupancy?.currentOccupancy ?? 0;
    final hasData = state.currentOccupancy != null && currentCount > 0;

    Color getBarColor() {
      if (percentage > 80) return Colors.red;
      if (percentage > 50) return Colors.orange;
      return Colors.green;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Current Occupancy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            hasData
                ? Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$currentCount',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: getBarColor(),
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'people',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    getBarColor()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: getBarColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('Empty gym!')),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePeriodToggle(BuildContext context, OccupancyState state) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: SegmentedButton<TimePeriod>(
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          segments: const [
            ButtonSegment<TimePeriod>(
              value: TimePeriod.daily,
              label: Text('Daily'),
              icon: Icon(Icons.today),
            ),
            ButtonSegment<TimePeriod>(
              value: TimePeriod.weekly,
              label: Text('Weekly'),
              icon: Icon(Icons.date_range),
            ),
            ButtonSegment<TimePeriod>(
              value: TimePeriod.monthly,
              label: Text('Monthly'),
              icon: Icon(Icons.calendar_month),
            ),
          ],
          selected: {state.timePeriod},
          onSelectionChanged: (Set<TimePeriod> selection) {
            if (selection.isNotEmpty) {
              context.read<OccupancyCubit>().changeTimePeriod(selection.first);
            }
          },
        ),
      ),
    );
  }

  Widget _buildOccupancyList(BuildContext context, OccupancyState state) {
    if (state.averageByHour.isEmpty) {
      return SliverToBoxAdapter(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No occupancy data available')),
          ),
        ),
      );
    }

    final sortedEntries = state.averageByHour.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = sortedEntries[index];
          final hour = entry.key;
          final occupancy = entry.value.toInt();
          final widthFactor = (occupancy / 100).clamp(0.0, 1.0);

          final timeString = hour > 12
              ? '${hour - 12} PM'
              : hour == 12
                  ? '12 PM'
                  : hour == 0
                      ? '12 AM'
                      : '$hour AM';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    alignment: Alignment.center,
                    child: Text(
                      timeString,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: widthFactor,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        Container(
                          height: 24,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '$occupancy',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: sortedEntries.length,
      ),
    );
  }

  Widget _buildPeakHoursList(BuildContext context, OccupancyState state) {
    if (state.peakHours.isEmpty) {
      return SliverToBoxAdapter(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No peak hours data available')),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final peak = state.peakHours[index];
          final hour = peak.hour;
          final formattedHour = hour > 12
              ? '${hour - 12} PM'
              : hour == 12
                  ? '12 PM'
                  : hour == 0
                      ? '12 AM'
                      : '$hour AM';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.access_time,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                formattedHour,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('EEEE, MMM d').format(peak.date),
              ),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${peak.currentOccupancy}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
        childCount: state.peakHours.length,
      ),
    );
  }
}
