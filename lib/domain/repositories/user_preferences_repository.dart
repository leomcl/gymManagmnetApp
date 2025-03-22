import '../entities/user_preferences.dart';

abstract class UserPreferencesRepository {
  /// Get user preferences by user ID
  Future<UserPreferences?> getUserPreferences(String userId);

  /// Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences);
}
