import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test/auth.dart';
import 'pages/customer_pages/customer_home_view.dart';
import 'package:test/pages/login_register_page.dart';
import 'package:test/pages/staff_pages/staff_home_view.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  // Function to get the user's role from Firestore
  Future<String?> _getUserRole() async {
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
    return null;  // If no user is authenticated or role is missing
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to Firebase Auth state changes (login/logout)
    return StreamBuilder(
      stream: Auth().authStateChanges,  // Auth state change stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for authentication
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // If user is authenticated, check their role
          return FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                // Show loading spinner while fetching the role
                return const Center(child: CircularProgressIndicator());
              }

              if (roleSnapshot.hasError) {
                // Show error message if there's an error fetching role
                return const Center(child: Text('Error fetching user role.'));
              }

              if (roleSnapshot.hasData) {
                String? role = roleSnapshot.data;

                if (role == 'customer') {
                  // If user is a customer, navigate to CustomerHomeView (with BottomNavigationBar)
                  return CustomerHomeView();
                } else if (role == 'staff') {
                  // If user is a staff, navigate to StaffHomeView (with BottomNavigationBar)
                  return StaffHomeView();
                } else {
                  // If role is not defined, show an error message
                  return const Center(child: Text('Role not defined.'));
                }
              }

              // If no role is found, show an error message
              return const Center(child: Text('No user role found.'));
            },
          );
        } else {
          // If the user is not authenticated, show the LoginPage
          return const LoginPage();
        }
      },
    );
  }
}
