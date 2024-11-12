import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/auth.dart';
import 'package:test/pages/login_register_page.dart';
import 'package:test/utils/access_code_generator.dart';

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});

  @override
  CustomerViewState createState() => CustomerViewState();
}

class CustomerViewState extends State<CustomerView> {
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

    final String code = await AccessCodeGenerator.generateAndSaveCode(
      userId: user!.uid,
      isEntry: isEntry,
    );

    setState(() {
      if (isEntry) {
        generatedEntryCode = code;
      } else {
        generatedExitCode = code;
      }
    });
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'No user email',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isMembershipValid ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMembershipValid ? Icons.check_circle : Icons.cancel,
                    color: isMembershipValid ? Colors.green[700] : Colors.red[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMembershipValid ? 'Active Membership' : 'Inactive Membership',
                    style: TextStyle(
                      color: isMembershipValid ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isMembershipValid ? () => _generateTempCode(true) : null,
                    icon: const Icon(Icons.login),
                    label: const Text('Entry Code'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isMembershipValid ? () => _generateTempCode(false) : null,
                    icon: const Icon(Icons.logout),
                    label: const Text('Exit Code'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (generatedEntryCode != null || generatedExitCode != null) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              if (generatedEntryCode != null)
                _buildCodeDisplay('Entry Code', generatedEntryCode!),
              if (generatedEntryCode != null && generatedExitCode != null)
                const SizedBox(height: 16),
              if (generatedExitCode != null)
                _buildCodeDisplay('Exit Code', generatedExitCode!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCodeDisplay(String label, String code) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gym Access',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 20),
                    _buildCodeSection(),
                  ],
                ),
              ),
            ),
    );
  }
}
