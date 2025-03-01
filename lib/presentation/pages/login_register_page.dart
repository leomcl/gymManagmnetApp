import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/presentation/cubit/auth/auth_cubit.dart';
import 'package:test/presentation/cubit/auth/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  String? _selectedRole;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  // UI components
  Widget _title() {
    return const Text('Gym App');
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthError) {
          return Text('Error: ${state.message}',
              style: const TextStyle(color: Colors.red));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _submitButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  if (isLogin) {
                    context.read<AuthCubit>().signIn(
                          _controllerEmail.text,
                          _controllerPassword.text,
                        );
                  } else {
                    if (_selectedRole != null) {
                      context.read<AuthCubit>().signUp(
                            _controllerEmail.text,
                            _controllerPassword.text,
                            _selectedRole!,
                          );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a role')),
                      );
                    }
                  }
                },
          child: isLoading
              ? const CircularProgressIndicator()
              : Text(isLogin ? 'Login' : 'Register'),
        );
      },
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
  }

  // Role selection widget (only visible during registration)
  Widget _roleSelection() {
    return isLogin
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Role:', style: TextStyle(fontSize: 16)),
              RadioListTile(
                title: const Text('Customer'),
                value: 'customer',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value.toString();
                  });
                },
              ),
              RadioListTile(
                title: const Text('Staff'),
                value: 'staff',
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value.toString();
                  });
                },
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _entryField('Email', _controllerEmail),
              _entryField('Password', _controllerPassword, isPassword: true),
              _errorMessage(),
              _roleSelection(),
              _submitButton(),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
} 