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
      // Set the time period to monthly by default when loading
      context.read<OccupancyCubit>()
        ..changeTimePeriod(TimePeriod.monthly)
        ..loadCurrentOccupancy();
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
                            _buildCurrentOccupancy(context, state),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Average Occupancy',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            // Time period toggle removed
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: _buildOccupancyList(context, state),
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
          DateFormat('MMMM yyyy').format(state.selectedDate),
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
        padding: const EdgeInsets.all(12.0),
        child: hasData
            ? Row(
                children: [
                  Icon(Icons.people, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Current: ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '$currentCount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getBarColor(),
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'people',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(getBarColor()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: getBarColor(),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(Icons.people, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Current Occupancy: Empty gym!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
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
                            color: const Color.fromARGB(255, 238, 238, 238),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
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

}
