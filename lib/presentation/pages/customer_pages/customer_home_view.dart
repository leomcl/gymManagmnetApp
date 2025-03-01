import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';
import 'package:test/presentation/pages/customer_pages/workout_selection_view.dart';
import 'package:test/presentation/pages/customer_pages/gym_stats_view.dart';

class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({super.key});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  String? generatedEntryCode;
  String? generatedExitCode;
  bool isMembershipValid =
      true; // Default to true until we implement membership checks
  bool isLoading = false;
  int _selectedIndex = 0;

  // Define your pages
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      const WorkoutSelectionPage(),
      const GymStatsView(),
      _buildProfilePage(),
    ];
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

        if (state is Authenticated) {
          email = state.email;
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
      listener: (context, state) {
        if (state.entryCode != null) {
          setState(() {
            generatedEntryCode = state.entryCode;
            isLoading = false;
          });
        }

        if (state.exitCode != null) {
          setState(() {
            generatedExitCode = state.exitCode;
            isLoading = false;
          });
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          setState(() {
            isLoading = false;
          });
        }
      },
      builder: (context, state) {
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading || !isMembershipValid
                            ? null
                            : () => _generateCode(context, true),
                        icon: const Icon(Icons.login),
                        label: const Text('Entry Code'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLoading || !isMembershipValid
                            ? null
                            : () => _generateCode(context, false),
                        icon: const Icon(Icons.logout),
                        label: const Text('Exit Code'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (generatedEntryCode != null ||
                    generatedExitCode != null) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  if (generatedEntryCode != null)
                    _buildCodeDisplay(
                        'Entry Code', generatedEntryCode!, Colors.green),
                  if (generatedEntryCode != null && generatedExitCode != null)
                    const SizedBox(height: 16),
                  if (generatedExitCode != null)
                    _buildCodeDisplay(
                        'Exit Code', generatedExitCode!, Colors.red),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodeDisplay(String label, String code, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
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
