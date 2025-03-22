import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';
import 'package:test/presentation/pages/customer_pages/workout_stats_view.dart';
import 'package:test/presentation/pages/customer_pages/gym_stats_view.dart';
import 'package:test/presentation/pages/customer_pages/class_view.dart';
import 'package:get_it/get_it.dart';
import 'package:test/presentation/cubit/gym_stats/gym_stats_cubit.dart';
import 'dart:developer';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:test/presentation/cubit/gym_classes/gym_classes_cubit.dart';

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
        create: (context) => GetIt.I<GymStatsCubit>(),
        child: const GymStatsView(),
      ),
      _buildProfilePage(),
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
            _buildCodeSection(),
            const SizedBox(height: 20),
            _buildRecentWorkoutsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              String? email;
              if (state is Authenticated) {
                email = state.email;
              }
              return Text(
                email ?? 'User Profile',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
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
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  email ?? 'No user email',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isMembershipValid ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMembershipValid ? Icons.check_circle : Icons.cancel,
                        color: isMembershipValid
                            ? Colors.green[700]
                            : Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isMembershipValid
                            ? 'Active Membership'
                            : 'Inactive Membership',
                        style: TextStyle(
                          color: isMembershipValid
                              ? Colors.green[700]
                              : Colors.red[700],
                          fontWeight: FontWeight.bold,
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
                      // Workout Selection Section
                      const Text(
                        'Select Your Workouts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3,
                          children: state.selectedWorkouts.entries.map((entry) {
                            return WorkoutButton(
                              label: entry.key,
                              isSelected: entry.value,
                              onSelected: () {
                                context
                                    .read<WorkoutCubit>()
                                    .toggleWorkout(entry.key);
                              },
                            );
                          }).toList(),
                        ),
                      ),
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

  // todo: Implement recent workouts section
  Widget _buildRecentWorkoutsSection() {
    // This is a placeholder for recent workouts section
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Workouts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.fitness_center, color: Colors.blue),
              ),
              title: const Text('Full Body Workout'),
              subtitle: const Text('Yesterday · 45 min'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to workout details
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: const Icon(Icons.directions_run, color: Colors.green),
              ),
              title: const Text('Cardio Session'),
              subtitle: const Text('3 days ago · 30 min'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to workout details
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // Navigate to all workouts
              },
              child: const Text('View All Workouts'),
            ),
          ],
        ),
      ),
    );
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

class WorkoutButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const WorkoutButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? Theme.of(context).primaryColor : Colors.white,
        foregroundColor:
            isSelected ? Colors.white : Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1.5,
        ),
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onSelected,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
