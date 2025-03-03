import 'package:flutter/material.dart';
import 'package:test/presentation/widgets/hourly_entries_chart.dart';
import 'package:test/presentation/cubit/gym_stats/gym_stats_cubit.dart';
import 'package:test/presentation/cubit/gym_stats/gym_stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GymStatsView extends StatefulWidget {
  const GymStatsView({super.key});

  @override
  State<GymStatsView> createState() => _GymStatsViewState();
}

class _GymStatsViewState extends State<GymStatsView> {
  @override
  void initState() {
    super.initState();
    context.read<GymStatsCubit>().startMonitoringOccupancy();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
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
                        Icon(
                          Icons.people,
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
                    BlocBuilder<GymStatsCubit, GymStatsState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state.errorMessage != null) {
                          return Text(
                            'Error: ${state.errorMessage}',
                            style: TextStyle(color: Colors.red[700]),
                          );
                        } else if (state.occupancy != null) {
                          return Row(
                            children: [
                              Text(
                                '${state.occupancy}',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'people currently in the gym',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
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
            ),
            const SizedBox(height: 24),
            Card(
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
                        Icon(
                          Icons.insert_chart,
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
                    const SizedBox(
                      height: 300,
                      child: HourlyEntriesChart(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
