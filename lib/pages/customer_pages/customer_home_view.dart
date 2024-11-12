import 'package:flutter/material.dart';
import 'customer_view.dart';
import 'package:test/pages/customer_pages/gym_stats_view.dart';
import 'package:test/pages/customer_pages/workout_selection_view.dart';

class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({super.key});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  int _currentIndex = 0;

  // List of pages for the BottomNavigationBar
  final List<Widget> _pages = [
    CustomerView(),
    GymStatsView(),
    WorkoutSelectionPage(),  // Add the Workout Selection Page
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
        currentIndex: _currentIndex,  
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Customer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Gym Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
        ],
      ),
    );
  }
}
