import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_view.dart'; // Customer View Screen
import 'staff_view.dart'; // Staff View Screen

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

  // Sign in method
  Future<void> signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Get the user role and navigate to the appropriate screen
      await _navigateBasedOnRole(userCredential.user);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Create account method with Firestore membership status and role selection
  Future<void> createUserWithEmailAndPassword() async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Get the newly created user's UID
      User? user = userCredential.user;

      // Store the new user's information in Firestore
      if (user != null && _selectedRole != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'membershipStatus': false, // Default membership status
          'role': _selectedRole, // Store role as customer or staff
        });
        // Navigate to the appropriate screen based on role
        await _navigateBasedOnRole(user);
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

  // Function to get user role and navigate accordingly
  Future<void> _navigateBasedOnRole(User? user) async {
    if (user == null) return;

    // Fetch the user role from Firestore
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      String role = doc['role'];

      // Ensure the widget is still mounted before navigating
      if (mounted) {
        if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomerView()),
          );
        } else if (role == 'staff') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StaffView()),
          );
        }
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
            _roleSelection(), // Show role selection during registration
            _submitButton(),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}
