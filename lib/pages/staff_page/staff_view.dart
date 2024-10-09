import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/auth.dart'; // Ensure you have your auth handling here
import 'package:test/pages/login_register_page.dart'; // For navigating to login page after sign out

class StaffView extends StatefulWidget {
  @override
  _StaffViewState createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {
  final TextEditingController _codeController =
      TextEditingController(); // For inputting access code
  String? _validationMessage; // To display validation results
  bool _isLoading = false; // For showing a loading indicator

  // Function to validate the access code
  Future<void> _validateAccessCode() async {
    String code = _codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _validationMessage = 'Please enter an access code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _validationMessage = null; // Clear previous messages
    });

    // Fetch the document from Firestore with the given code
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('gymAccessCodes')
        .doc(code)
        .get();

    if (!doc.exists) {
      setState(() {
        _validationMessage = 'This code does not exist.';
        _isLoading = false;
      });
      return;
    }

    // Extract data from the document and check expiry time
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime expiryTime = (data['expiryTime'] as Timestamp).toDate();

    if (expiryTime.isBefore(DateTime.now())) {
      // If the code is expired, delete the document and show expired message
      await FirebaseFirestore.instance
          .collection('gymAccessCodes')
          .doc(code)
          .delete();
      setState(() {
        _validationMessage = 'This code has expired.';
        _isLoading = false;
      });
    } else {
      // If the code is valid, delete the document and show valid message
      await FirebaseFirestore.instance
          .collection('gymAccessCodes')
          .doc(code)
          .delete();
      setState(() {
        _validationMessage = 'Access code is valid. User ID: ${data['userId']}';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await Auth().signOut(); // Sign out the user from FirebaseAuth
    // Navigate to the login page after sign-out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginPage()), // Replace with the login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff - Validate Access Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Logout icon button
            onPressed: _signOut, // Sign out on button press
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter Customer Access Code:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Text field to enter the access code
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'Enter access code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to trigger validation
            ElevatedButton(
              onPressed: _validateAccessCode,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Validate Code'),
            ),
            const SizedBox(height: 20),

            // Display validation message (if any)
            if (_validationMessage != null)
              Text(
                _validationMessage!,
                style: TextStyle(
                  fontSize: 18,
                  color: _validationMessage!.contains('valid')
                      ? Colors.green
                      : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
