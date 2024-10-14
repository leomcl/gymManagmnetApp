import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/auth.dart';
import 'package:test/pages/login_register_page.dart';
import 'package:test/pages/staff_page/gym_counter.dart';
import 'package:test/pages/staff_page/gym_logger.dart';

class StaffView extends StatefulWidget {
  @override
  _StaffViewState createState() => _StaffViewState();
}

class _StaffViewState extends State<StaffView> {
  final TextEditingController _entryCodeController =
      TextEditingController(); // For inputting entry access code
  final TextEditingController _exitCodeController =
      TextEditingController(); // For inputting exit access code
  String? _validationMessage; // To display validation results
  bool _isLoading = false; // For showing a loading indicator
  final GymCounter _gymCounter =
      GymCounter(); // Instance for tracking gym count
  final GymLogManager _gymLogManager =
      GymLogManager(); // Instance for logging user events

  // Function to validate the entry access code and update count when someone enters
  Future<void> _validateEntryCode() async {
    String code = _entryCodeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _validationMessage = 'Please enter an entry access code.';
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
        _validationMessage = 'Invalid code. This code does not exist.';
        _isLoading = false;
      });
      return;
    }

    // Extract data from the document and check expiry time
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    DateTime expiryTime = (data['expiryTime'] as Timestamp).toDate();
    String userId = data['userId'];

    if (expiryTime.isBefore(DateTime.now())) {
      // If the code is expired, delete the document and show expired message
      await FirebaseFirestore.instance
          .collection('gymAccessCodes')
          .doc(code)
          .delete();
      setState(() {
        _validationMessage = 'This code has expired and has been deleted.';
        _isLoading = false;
      });
    } else {
      // If the code is valid, log the entry, increment the gym count, and delete the document
      await _gymLogManager.logUserEntry(userId); // Log user entry
      await _gymCounter.incrementGymCount(); // Update gym count

      await FirebaseFirestore.instance
          .collection('gymAccessCodes')
          .doc(code)
          .delete();
      setState(() {
        _validationMessage =
            'Access code is valid, user entered. User ID: ${userId}';
        _isLoading = false;
      });
    }
  }

  // Function to handle exit access code and decrement the gym count
  Future<void> _validateExitCode() async {
    String code = _exitCodeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _validationMessage = 'Please enter an exit access code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _validationMessage = null;
    });

    // Fetch the document from Firestore with the given code
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('gymAccessCodes')
        .doc(code)
        .get();

    if (!doc.exists) {
      setState(() {
        _validationMessage = 'Invalid exit code. This code does not exist.';
        _isLoading = false;
      });
      return;
    }

    // Extract data from the document and get the user ID for exit
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String userId = data['userId'];

    // Log the user exit and decrement the gym count
    await _gymLogManager.logUserExit(userId); // Log user exit
    await _gymCounter.decrementGymCount(); // Update gym count

    // Optionally delete the access code if it's a single-use code (like entry)
    await FirebaseFirestore.instance
        .collection('gymAccessCodes')
        .doc(code)
        .delete();

    setState(() {
      _validationMessage = 'User exit recorded successfully. User ID: $userId';
      _isLoading = false;
    });
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
              'Enter Customer Entry Access Code:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Text field to enter the entry access code
            TextField(
              controller: _entryCodeController,
              decoration: const InputDecoration(
                hintText: 'Enter entry access code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to trigger validation for entry
            ElevatedButton(
              onPressed: _validateEntryCode,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Validate Entry Code'),
            ),
            const SizedBox(height: 20),

            const Text(
              'Enter Customer Exit Access Code:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Text field to enter the exit access code
            TextField(
              controller: _exitCodeController,
              decoration: const InputDecoration(
                hintText: 'Enter exit access code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to trigger validation for exit
            ElevatedButton(
              onPressed: _validateExitCode,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Validate Exit Code'),
            ),
            const SizedBox(height: 20),

            // Display validation message (if any)
            if (_validationMessage != null)
              Text(
                _validationMessage!,
                style: TextStyle(
                  fontSize: 18,
                  color: _validationMessage!.contains('User ID') ||
                          _validationMessage!.contains('recorded')
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
