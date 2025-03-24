import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
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
}
