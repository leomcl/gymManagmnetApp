import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test/domain/entities/user_preferences.dart';
import 'package:test/domain/repositories/user_preferences_repository.dart';
import 'package:test/domain/usecases/auth/get_current_user.dart';
import 'package:get_it/get_it.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({Key? key}) : super(key: key);

  @override
  _UserPreferencesScreenState createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  String _selectedTimeOfDay = 'any';
  bool _isLoading = true;
  String? _userId;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = await GetIt.I<GetCurrentUser>().call();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      _userId = currentUser.uid;

      final preferences = await GetIt.I<UserPreferencesRepository>()
          .getUserPreferences(_userId!);

      if (preferences != null) {
        setState(() {
          // Convert 1-indexed weekdays to 0-indexed array positions
          for (final day in preferences.preferredWorkoutDays) {
            _selectedDays[day - 1] = true;
          }

          _selectedTimeOfDay = preferences.preferredTimeOfDay ?? 'any';
        });
      }
    } catch (e) {
      _showSnackBar('Error loading preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserPreferences() async {
    if (_userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Convert 0-indexed array positions to 1-indexed weekdays
      final List<int> preferredDays = [];
      for (int i = 0; i < _selectedDays.length; i++) {
        if (_selectedDays[i]) {
          preferredDays.add(i + 1);
        }
      }

      final preferences = UserPreferences(
        userId: _userId!,
        preferredWorkoutDays: preferredDays,
        preferredTimeOfDay:
            _selectedTimeOfDay == 'any' ? null : _selectedTimeOfDay,
      );

      await GetIt.I<UserPreferencesRepository>()
          .saveUserPreferences(preferences);
      _showSnackBar('Preferences saved successfully');
    } catch (e) {
      _showSnackBar('Error saving preferences: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Preferences'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferred Workout Days',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the days you typically prefer to work out:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Days selection
                    ...List.generate(7, (index) {
                      return CheckboxListTile(
                        title: Text(daysOfWeek[index]),
                        value: _selectedDays[index],
                        onChanged: (value) {
                          setState(() {
                            _selectedDays[index] = value ?? false;
                          });
                        },
                      );
                    }),

                    const Divider(height: 32),

                    // Time of day preference
                    const Text(
                      'Preferred Time of Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When do you prefer to work out?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    RadioListTile<String>(
                      title: const Text('Any time'),
                      value: 'any',
                      groupValue: _selectedTimeOfDay,
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeOfDay = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Morning (6am - 12pm)'),
                      value: 'morning',
                      groupValue: _selectedTimeOfDay,
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeOfDay = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Afternoon (12pm - 5pm)'),
                      value: 'afternoon',
                      groupValue: _selectedTimeOfDay,
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeOfDay = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Evening (5pm - 10pm)'),
                      value: 'evening',
                      groupValue: _selectedTimeOfDay,
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeOfDay = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveUserPreferences,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Preferences'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
