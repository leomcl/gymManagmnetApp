import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/auth.dart';
import 'package:test/pages/customer_pages/customer_home_view.dart';
import 'package:test/pages/staff_pages/staff_home_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  String? _selectedRole; // To store the selected role

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  final Auth _auth = Auth(); // Create an instance of Auth class

  // Sign in method
  Future<void> signInWithEmailAndPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        _controllerEmail.text,
        _controllerPassword.text,
      );

      // Navigate to the appropriate screen based on the user's role
      await _navigateBasedOnRole();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Create account method with role selection
  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (_selectedRole != null) {
        await _auth.createUserWithEmailAndPassword(
          _controllerEmail.text,
          _controllerPassword.text,
          _selectedRole!, // Ensure the role is passed
        );

        // Navigate to the appropriate screen based on role
        await _navigateBasedOnRole();
      } else {
        setState(() {
          errorMessage = 'Please select a role!';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Function to navigate based on role
  Future<void> _navigateBasedOnRole() async {
    String? role = await _auth.getUserRole();

    if (role != null && mounted) {
      if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomeView()),
        );
      } else if (role == 'staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StaffHomeView()),
        );
      }
    }
  }

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
    return Text(errorMessage == '' ? '' : 'Hmm? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
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
      body: Container(
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
    );
  }
}
