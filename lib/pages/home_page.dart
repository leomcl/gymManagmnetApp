import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import 'package:test/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = Auth().currentUser;  // Current user from Firebase Auth

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget _title() {
    return const Text('Gym App');
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  // Function to fetch Firestore user data
  Future<DocumentSnapshot> _getUserData() async {
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    }
    throw 'No user found!';
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
            // Display user email
            Text(user?.email ?? 'No user email'),
            
            // Use FutureBuilder to fetch Firestore data
            FutureBuilder<DocumentSnapshot>(
              future: _getUserData(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();  // Show loading indicator while fetching data
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('No user data found.');
                }

                // Extract user data from Firestore document
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  children: [
                    Text('Membership Status: ${data['membershipStatus'] ? 'Valid' : 'Invalid'}'),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),  // Spacing
            _signOutButton(),  // Sign out button
          ],
        ),
      ),
    );
  }
}
