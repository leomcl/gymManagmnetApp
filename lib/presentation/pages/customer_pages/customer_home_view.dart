import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';
import 'package:test/presentation/pages/customer_pages/workout_stats_view.dart';
import 'package:test/presentation/pages/customer_pages/class_view.dart';
import 'package:get_it/get_it.dart';
import 'dart:developer';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:test/presentation/cubit/gym_classes/gym_classes_cubit.dart';
import 'package:test/presentation/widgets/workout_selection_widget.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_cubit.dart';
import 'package:test/presentation/cubit/workout_selection/workout_selection_state.dart';
import 'package:test/presentation/pages/customer_pages/gym_stats_view.dart';
import 'package:test/presentation/cubit/occupancy/occupancy_cubit.dart';
import 'package:test/presentation/widgets/suggestions_widget.dart';
import 'package:test/presentation/cubit/suggestions/suggestions_cubit.dart';
import 'package:test/presentation/pages/customer_pages/profile_view.dart';
import 'package:test/presentation/cubit/profile/profile_cubit.dart';

class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({super.key});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  String? generatedEntryCode;
  String? generatedExitCode;
  bool isLoading = false;
  int _selectedIndex = 0;
  String? _lastShownExitCode;
  String? _lastShownEntryCode;
  int _futureBuilderKey = 0;

  // Define your pages
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      const WorkoutSelectionPage(),
      BlocProvider(
        create: (context) => GetIt.I<GymClassesCubit>(),
        child: const ClassView(),
      ),
      BlocProvider(
        create: (context) => GetIt.I<OccupancyCubit>(),
        child: const GymStatsView(),
      ),
      BlocProvider(
        create: (context) => GetIt.I<ProfileCubit>(),
        child: const ProfileView(),
      ),
    ];

    // Check gym status when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is Authenticated) {
        context.read<WorkoutCubit>().checkGymStatus();
      }
    });
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Display today's optimal times section only when user isn't in the gym
            BlocBuilder<WorkoutCubit, WorkoutState>(
              builder: (context, state) {
                final authState = context.read<AuthCubit>().state;
                String? userId;
                if (authState is Authenticated) {
                  userId = authState.userId;
                }

                return FutureBuilder<bool>(
                  future: userId != null
                      ? context
                          .read<WorkoutCubit>()
                          .isUserInGymUseCase(userId: userId)
                      : Future.value(false),
                  builder: (context, snapshot) {
                    final isInGym = snapshot.data ?? false;

                    if (!isInGym) {
                      return Column(
                        children: [
                          _buildTodayOptimalTimes(),
                          const SizedBox(height: 20),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),

            _buildCodeSection(),
            const SizedBox(height: 20),
            _buildRecentWorkoutsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String? email;
        bool isMembershipValid = false;
        if (state is Authenticated) {
          email = state.email;
          isMembershipValid = state.membershipStatus;
          log(state.toString());
        }

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 25,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email ?? 'No user email',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isMembershipValid
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isMembershipValid
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: isMembershipValid
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isMembershipValid
                                  ? 'Active Membership'
                                  : 'Inactive',
                              style: TextStyle(
                                color: isMembershipValid
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
    );
  }

  Future<void> _generateCode(BuildContext context, bool isEntry) async {
    setState(() {
      isLoading = true;
    });

    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      context.read<WorkoutCubit>().generateCode(
            userId: authState.userId,
            isEntry: isEntry,
          );
    }
  }

  // Add this new method to build today's optimal training times
  Widget _buildTodayOptimalTimes() {
    return BlocProvider(
      create: (context) => GetIt.I<SuggestionsCubit>(),
      child: BlocBuilder<SuggestionsCubit, SuggestionsState>(
        builder: (context, state) {
          if (state is SuggestionsInitial) {
            context.read<SuggestionsCubit>().loadSuggestions();
            return const SizedBox.shrink();
          } else if (state is SuggestionsLoading) {
            return const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (state is SuggestionsLoaded) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Optimal training times today',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (state.todayOptimalTimes.isEmpty)
                      const Text('No optimal training times for today')
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.todayOptimalTimes
                            .map((hour) => _buildTimeChip(context, hour, true))
                            .toList(),
                      ),
                  ],
                ),
              ),
            );
          } else if (state is SuggestionsError) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Optimal training times today',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Unable to load optimal times: ${state.message}'),
                  ],
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context, int hour, bool isToday) {
    final now = DateTime.now();
    final isCurrentHour = now.hour == hour && isToday;
    final isPastHour = now.hour > hour && isToday;

    return Chip(
      backgroundColor: isCurrentHour
          ? Theme.of(context).colorScheme.secondary.withOpacity(0.7)
          : isPastHour
              ? Colors.grey.withOpacity(0.3)
              : Theme.of(context).primaryColor.withOpacity(0.1),
      label: Text(
        _formatHour(hour),
        style: TextStyle(
          color: isCurrentHour
              ? Colors.white
              : isPastHour
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
          fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      avatar: isCurrentHour
          ? Icon(Icons.access_time_filled, size: 16, color: Colors.white)
          : null,
    );
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:00 $period';
  }

  Widget _buildCodeSection() {
    return BlocConsumer<WorkoutCubit, WorkoutState>(
      listenWhen: (previous, current) =>
          previous.entryCode != current.entryCode ||
          previous.exitCode != current.exitCode,
      listener: (context, state) {
        setState(() {
          isLoading = false;
        });

        // Only show exit code dialog if the exit code is new or changed
        if (state.exitCode != null && state.exitCode != _lastShownExitCode) {
          _lastShownExitCode = state.exitCode;
          _showCodeDialog('Exit Code', state.exitCode!, Colors.red);
        }
        // Only show entry code dialog if the entry code is new or changed
        else if (state.entryCode != null &&
            state.entryCode != _lastShownEntryCode) {
          _lastShownEntryCode = state.entryCode;
          _showCodeDialog('Entry Code', state.entryCode!, Colors.green);
        }
      },
      builder: (context, state) {
        // Get membership status from auth state
        bool isMembershipValid = false;
        final authState = context.read<AuthCubit>().state;
        String? userId;
        if (authState is Authenticated) {
          isMembershipValid = authState.membershipStatus;
          userId = authState.userId;
        }

        return FutureBuilder<bool>(
          key: ValueKey(_futureBuilderKey),
          future: userId != null
              ? context.read<WorkoutCubit>().isUserInGymUseCase(userId: userId)
              : Future.value(false),
          builder: (context, snapshot) {
            final isInGym = snapshot.data ?? false;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isInGym) ...[
                      ElevatedButton.icon(
                        onPressed: isLoading || !isMembershipValid
                            ? null
                            : () => _generateCode(context, true),
                        icon: const Icon(Icons.login),
                        label: const Text('Enter Gym'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Sync workout selection cubit with main workout cubit
                      Builder(builder: (context) {
                        _syncWorkoutSelectionCubit(context, isInGym);
                        return const WorkoutSelectionWidget();
                      }),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed:
                            isLoading ? null : () => _handleGymExit(context),
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Leave Gym'),
                      ),
                    ],
                    if (isLoading) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleGymExit(BuildContext context) async {
    final workoutCubit = context.read<WorkoutCubit>();
    final workoutSelectionCubit = context.read<WorkoutSelectionCubit>();
    final workoutSelectionState = workoutSelectionCubit.state;

    // Get selected workouts from the WorkoutSelectionCubit
    final selectedWorkouts =
        Map<String, bool>.from(workoutSelectionCubit.getSelectedWorkouts());

    // Add a tag to indicate if this was a solo workout or class
    if (workoutSelectionState.workoutMode == WorkoutMode.solo) {
      selectedWorkouts['Solo'] = true;
      selectedWorkouts['Class'] = false;
    } else {
      selectedWorkouts['Solo'] = false;
      selectedWorkouts['Class'] = true;

      // If a class was selected, add its name as a tag
      if (workoutSelectionState.selectedClass != null) {
        selectedWorkouts[
            'Class_${workoutSelectionState.selectedClass!.className}'] = true;
      }
    }

    // Update WorkoutCubit with the modified selected workouts
    workoutCubit.emit(workoutCubit.state.copyWith(
      selectedWorkouts: selectedWorkouts,
    ));

    // Continue with handling gym exit
    await workoutCubit.handleGymExit();
  }

  void _showCodeDialog(String title, String code, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Container(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Use this code at the gate:'),
                  const SizedBox(height: 16),
                  // QR Code with fixed size container
                  Container(
                    width: 200,
                    height: 200,
                    child: QrImageView(
                      data: code,
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Manual text code (as backup)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Force a refresh of the FutureBuilder
                setState(() {
                  _futureBuilderKey++; // Increment the key to force rebuild
                  _pages[0] = _buildHomePage(); // Rebuild the home page
                });

                // Also refresh gym status in the cubit
                final authState = this.context.read<AuthCubit>().state;
                if (authState is Authenticated) {
                  this.context.read<WorkoutCubit>().checkGymStatus();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentWorkoutsSection() {
    return BlocProvider(
      create: (context) => GetIt.I<SuggestionsCubit>(),
      child: const SuggestionsWidget(),
    );
  }

  void _syncWorkoutSelectionCubit(BuildContext context, bool isInGym) {
    if (isInGym) {
      final workoutState = context.read<WorkoutCubit>().state;
      context.read<WorkoutSelectionCubit>().syncWithWorkoutState(workoutState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym App'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // This is important for 4+ items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
