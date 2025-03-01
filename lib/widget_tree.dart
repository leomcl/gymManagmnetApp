import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';
import 'package:test/presentation/pages/customer_pages/customer_home_view.dart';
import 'package:test/presentation/pages/login_register_page.dart';
import 'package:test/presentation/pages/staff_pages/staff_home_view.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  void initState() {
    super.initState();
    // Call the method directly instead of adding an event
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is Authenticated) {
          final role = state.role;

          if (role == 'customer') {
            return const CustomerHomeView();
          } else if (role == 'staff') {
            return const StaffHomeView();
          } else {
            return const Center(child: Text('Role not defined.'));
          }
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
