import 'package:flutter/material.dart';
import 'customer_view.dart';
import 'package:test/pages/customer_pages/gym_stats_view.dart';
class CustomerHomeView extends StatefulWidget {
  @override
  _CustomerHomeViewState createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  int _currentIndex = 0;  // Track the currently selected tab

  // List of pages for the BottomNavigationBar
  final List<Widget> _pages = [
    CustomerView(),
    GymStatsView(),
  ];

  // Function to handle tab switching
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Management - Customer'),
      ),
      body: _pages[_currentIndex],  // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,  // Track selected tab
        onTap: _onTabTapped,          // Handle tab switching
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),  // Icon for Customer View
            label: 'Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),  // Icon for Gym Stats View
            label: 'Gym Stats',
          ),
        ],
      ),
    );
  }
}
