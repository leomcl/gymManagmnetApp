import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';
import 'package:test/presentation/cubit/workout/workout_cubit.dart';
import 'package:test/presentation/cubit/workout/workout_state.dart';
import 'package:test/presentation/pages/customer/workout_selection_view.dart';

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
                    _buildCodeDisplay('Entry Code', generatedEntryCode!),
                  if (generatedEntryCode != null && generatedExitCode != null)
                    const SizedBox(height: 16),
                  if (generatedExitCode != null)
                    _buildCodeDisplay('Exit Code', generatedExitCode!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodeDisplay(String label, String code) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkoutSelectionPage(),
            ),
          );
        },
        icon: const Icon(Icons.fitness_center),
        label: const Text('Start Workout Session'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gym Access',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildCodeSection(),
              const SizedBox(height: 20),
              _buildWorkoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
