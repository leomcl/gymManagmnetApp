import 'package:flutter/material.dart';

class StaffHomeView extends StatefulWidget {
  const StaffHomeView({super.key});

  @override
  State<StaffHomeView> createState() => _StaffHomeViewState();
}

class _StaffHomeViewState extends State<StaffHomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Home'),
      ),
      body: const Center(
        child: Text('Staff Home View'),
      ),
    );
  }
} 