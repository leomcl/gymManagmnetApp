import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:test/auth.dart';
import 'package:test/pages/login_register_page.dart';
import 'dart:math';

class CustomerView extends StatefulWidget {
  CustomerView({Key? key}) : super(key: key);

  @override
  _CustomerViewState createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  final User? user = Auth().currentUser; 
  String? generatedCode; 
  bool isMembershipValid = false;
  bool isLoading =
      true;

  // Sign out method to sign out and navigate back to the login page
  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginPage()),
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
    _getUserData();
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

    // Set an expiry time
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
          : null,
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
            onPressed: signOut,
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

                  const SizedBox(height: 20),

                  // Show membership status
                  Text(
                      'Membership Status: ${isMembershipValid ? 'Valid' : 'Invalid'}'),

                  const SizedBox(height: 20),

                  _getCodeButton(),

                  const SizedBox(height: 20),

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
