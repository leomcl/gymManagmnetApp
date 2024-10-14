import 'package:flutter/material.dart';
import 'package:test/pages/staff_page/staff_view.dart';  // Import your StaffView
import 'package:test/pages/gym_stats_page/gym_stats_view.dart';

class StaffHomeView extends StatefulWidget {
  @override
  _StaffHomeViewState createState() => _StaffHomeViewState();
}

class _StaffHomeViewState extends State<StaffHomeView> {
  int _currentIndex = 0;  // Track the currently selected tab

  // List of pages to switch between
  final List<Widget> _pages = [
    StaffView(),     // Page for StaffView
    GymStatsView(),  // Page for GymStatsView
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
        title: const Text('Gym Management - Staff'),  // Static AppBar
      ),
      body: _pages[_currentIndex],  // Dynamic content based on selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,  // Current selected tab index
        onTap: _onTabTapped,          // Function to handle tab switching
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),     // Icon for Staff View
            label: 'Staff',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Icon for Gym Stats View
            label: 'Gym Stats',
          ),
        ],
      ),
    );
  }
}
