import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:test/auth.dart';
import 'package:test/pages/login_register_page.dart'; // Import LoginPage to navigate after sign out
import 'dart:math'; // Import for random code generation

class CustomerView extends StatefulWidget {
  CustomerView({Key? key}) : super(key: key);

  @override
  _CustomerViewState createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  final User? user = Auth().currentUser; // Current user from Firebase Auth
  String? generatedCode; // Variable to store the generated code
  bool isMembershipValid = false; // Variable to store membership status
  bool isLoading =
      true; // For loading indicator while fetching membership status

  // Sign out method to sign out and navigate back to the login page
  Future<void> signOut() async {
    await Auth().signOut(); // Firebase sign out
    // Navigate to the login page after signing out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginPage()), // Replace the current view with LoginPage
    );
  }

  Widget _title() {
    return const Text('Gym App');
  }

  // Function to fetch Firestore user data and update membership status
  Future<void> _getUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          isMembershipValid = data['membershipStatus'] == true;
          isLoading = false;
        });
      } else {
        throw 'User data not found!';
      }
    } else {
      throw 'No user found!';
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData(); // Fetch membership status when the screen loads
  }

  // Function to generate a temporary access code and store it in Firestore
  Future<void> _generateTempCode() async {
    if (user == null) {
      throw 'No user found!';
    }

    // Generate a random 6-digit code
    final Random random = Random();
    final String code =
        (random.nextInt(900000) + 100000).toString(); // 6-digit code

    // Set an expiry time (e.g., 1 hour from now)
    final DateTime expiryTime = DateTime.now().add(const Duration(hours: 1));

    // Store the code and related information in Firestore
    await FirebaseFirestore.instance
        .collection('gymAccessCodes')
        .doc(code)
        .set({
      'userId': user!.uid,
      'expiryTime': expiryTime,
    });

    // Set the generated code to the state so it can be displayed
    setState(() {
      generatedCode = code;
    });
  }

  Widget _getCodeButton() {
    return ElevatedButton(
      onPressed: isMembershipValid
          ? _generateTempCode
          : null, // Disable button if membership is invalid
      child: const Text('Get Code'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut, // Trigger sign out when button is pressed
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Loading indicator while fetching user data
          : Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Display user email
                  Text(user?.email ?? 'No user email'),

                  const SizedBox(height: 20), // Spacing

                  // Show membership status
                  Text(
                      'Membership Status: ${isMembershipValid ? 'Valid' : 'Invalid'}'),

                  const SizedBox(height: 20), // Spacing

                  // Display the Get Code button, only enabled if membership is valid
                  _getCodeButton(),

                  const SizedBox(height: 20), // Spacing

                  // Display the generated code, if available
                  if (generatedCode != null)
                    Text(
                      'Your Access Code: $generatedCode',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
    );
  }
}
