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
  String? generatedEntryCode;
  String? generatedExitCode;
  bool isMembershipValid = false;
  bool isLoading = true;

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _title() {
    return const Text('Gym App');
  }

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

  Future<void> _generateTempCode(bool isEntry) async {
    if (user == null) {
      throw 'No user found!';
    }

    final Random random = Random();
    String code;

    // Generate a random even or odd 6-digit code based on isEntry flag
    if (isEntry) {
      code = ((random.nextInt(450000) * 2) + 100000).toString(); // Even number
    } else {
      code = ((random.nextInt(450000) * 2) + 100001).toString(); // Odd number
    }

    final DateTime expiryTime = DateTime.now().add(const Duration(hours: 1));

    await FirebaseFirestore.instance
        .collection('gymAccessCodes')
        .doc(code)
        .set({
      'userId': user!.uid,
      'expiryTime': expiryTime,
      'type': isEntry ? 'enter' : 'exit',
    });

    setState(() {
      if (isEntry) {
        generatedEntryCode = code;
      } else {
        generatedExitCode = code;
      }
    });
  }

  Widget _getCodeButton({required String label, required bool isEntry}) {
    return ElevatedButton(
      onPressed: isMembershipValid ? () => _generateTempCode(isEntry) : null,
      child: Text(label),
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
              child: CircularProgressIndicator(),
            )
          : Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(user?.email ?? 'No user email'),
                  const SizedBox(height: 20),
                  Text(
                      'Membership Status: ${isMembershipValid ? 'Valid' : 'Invalid'}'),
                  const SizedBox(height: 20),
                  _getCodeButton(label: 'Get Entry Code', isEntry: true),
                  const SizedBox(height: 20),
                  _getCodeButton(label: 'Get Exit Code', isEntry: false),
                  const SizedBox(height: 20),
                  if (generatedEntryCode != null)
                    Text(
                      'Your Entry Code: $generatedEntryCode',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 20),
                  if (generatedExitCode != null)
                    Text(
                      'Your Exit Code: $generatedExitCode',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
    );
  }
}
