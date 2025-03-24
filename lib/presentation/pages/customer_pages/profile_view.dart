import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';
import 'package:test/presentation/cubit/profile/profile_cubit.dart';
import 'package:test/presentation/cubit/profile/profile_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

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
    return days[day - 1 < 0
        ? 0
        : day - 1 > 6
            ? 6
            : day - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          String? email;
          String? userId;
          if (authState is Authenticated) {
            email = authState.email;
            userId = authState.userId;
            // Load user profile data when authenticated
            context.read<ProfileCubit>().loadUserProfileData(userId);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 100, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  email ?? 'User Profile',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // User workout preferences section
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    if (profileState.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (profileState.error != null) {
                      return Text(
                        'Error: ${profileState.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profileState.preferredDays.isNotEmpty) ...[
                          const Text(
                            'Your Preferred Workout Days:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: profileState.preferredDays
                                .map((day) => Chip(
                                      label: Text(_getDayName(day)),
                                      backgroundColor: Colors.blue.shade100,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (profileState.preferredWorkouts.isNotEmpty) ...[
                          const Text(
                            'Your Preferred Workout Types:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: profileState.preferredWorkouts
                                .map((workout) => Chip(
                                      label: Text(workout),
                                      backgroundColor: Colors.green.shade100,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
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
        },
      ),
    );
  }
}
