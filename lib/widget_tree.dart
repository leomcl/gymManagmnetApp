import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/auth.dart';
import 'package:test/pages/customer_view.dart';
import 'package:test/pages/login_register_page.dart';
import 'package:test/pages/staff_view.dart'; // Add staff view import
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  Future<String?> _getUserRole() async {
    // Get the current user from Firebase Auth
    final user = Auth().currentUser;

    if (user != null) {
      // Fetch the user document from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return doc['role']; // Return the role ('customer' or 'staff')
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User is authenticated, now check their role
          return FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Loading spinner while role is being fetched
              }

              if (roleSnapshot.hasError) {
                return const Center(child: Text('Error fetching user role.'));
              }

              if (roleSnapshot.hasData) {
                // Navigate based on the role
                String? role = roleSnapshot.data;
                if (role == 'customer') {
                  return CustomerView();
                } else if (role == 'staff') {
                  return StaffView();
                } else {
                  return const Center(child: Text('Role not defined.'));
                }
              }

              return const Center(child: Text('No user role found.'));
            },
          );
        } else {
          // User is not authenticated, show login page
          return const LoginPage();
        }
      },
    );
  }
}
