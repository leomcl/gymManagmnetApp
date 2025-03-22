import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/gym_class.dart';
import '../../../presentation/cubit/gym_classes/gym_classes_cubit.dart';
import '../../../presentation/cubit/gym_classes/gym_classes_state.dart';

class ClassView extends StatefulWidget {
  const ClassView({super.key});

  @override
  State<ClassView> createState() => _ClassViewState();
}

class _ClassViewState extends State<ClassView> {
  final DateFormat dateFormat = DateFormat('EEE, MMM d');
  final DateFormat timeFormat = DateFormat('h:mm a');

  @override
  void initState() {
    super.initState();
    context.read<GymClassesCubit>().loadClasses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Classes'),
      ),
      body: BlocBuilder<GymClassesCubit, GymClassesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<GymClassesCubit>().loadClasses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildDateSelector(context, state),
              _buildFilterChips(context, state),
              Expanded(
                child: state.classes.isEmpty
                    ? _buildNoClassesFound(context, state)
                    : _buildClassList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, GymClassesState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.selectedDate != null
                ? dateFormat.format(state.selectedDate!)
                : 'Today',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.calendar_today),
            label: const Text('Select Date'),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      context.read<GymClassesCubit>().selectDate(picked);
    }
  }

  Widget _buildFilterChips(BuildContext context, GymClassesState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: state.filter == GymClassFilter.all,
            onSelected: (selected) {
              context.read<GymClassesCubit>().changeFilter(GymClassFilter.all);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Full Body'),
            selected: state.filter == GymClassFilter.fullBody,
            onSelected: (selected) {
              context
                  .read<GymClassesCubit>()
                  .changeFilter(GymClassFilter.fullBody);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Arms'),
            selected: state.filter == GymClassFilter.arms,
            onSelected: (selected) {
              context.read<GymClassesCubit>().changeFilter(GymClassFilter.arms);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Legs'),
            selected: state.filter == GymClassFilter.legs,
            onSelected: (selected) {
              context.read<GymClassesCubit>().changeFilter(GymClassFilter.legs);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Chest'),
            selected: state.filter == GymClassFilter.chest,
            onSelected: (selected) {
              context
                  .read<GymClassesCubit>()
                  .changeFilter(GymClassFilter.chest);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Cardio'),
            selected: state.filter == GymClassFilter.cardio,
            onSelected: (selected) {
              context
                  .read<GymClassesCubit>()
                  .changeFilter(GymClassFilter.cardio);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(BuildContext context, GymClassesState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: state.classes.length,
      itemBuilder: (context, index) {
        final gymClass = state.classes[index];
        return _buildClassCard(context, gymClass);
      },
    );
  }

  Widget _buildClassCard(BuildContext context, GymClass gymClass) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          context.read<GymClassesCubit>().getClassDetails(gymClass.classId);
          _showClassDetailsDialog(context, gymClass);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    gymClass.className,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    timeFormat.format(gymClass.classTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                dateFormat.format(gymClass.classTime),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: gymClass.tags.entries
                    .where((entry) => entry.value)
                    .map((entry) => Chip(
                          label: Text(entry.key),
                          backgroundColor: Colors.blue.shade100,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassDetailsDialog(BuildContext context, GymClass gymClass) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gymClass.className),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${dateFormat.format(gymClass.classTime)}'),
            Text('Time: ${timeFormat.format(gymClass.classTime)}'),
            const SizedBox(height: 8),
            const Text(
              'Tags:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: gymClass.tags.entries
                  .where((entry) => entry.value)
                  .map((entry) => Chip(
                        label: Text(entry.key),
                        backgroundColor: Colors.blue.shade100,
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<GymClassesCubit>().clearSelectedClass();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoClassesFound(BuildContext context, GymClassesState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 60, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'No Classes Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.selectedDate != null
                ? 'No classes scheduled for ${dateFormat.format(state.selectedDate!)}'
                : 'No classes match the selected filter',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
