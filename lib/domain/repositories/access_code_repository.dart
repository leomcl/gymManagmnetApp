abstract class AccessCodeRepository {
  /// Generates an access code for entry to or exit from the gym
  ///
  /// [userId] is the unique identifier of the user
  /// [isEntry] indicates whether this is an entry code (true) or exit code (false)
  ///
  /// Returns a String representing the generated access code
  Future<String> generateAccessCode({
    required String userId,
    required bool isEntry,
    Duration? expiry,
  });

  /// Validates an access code
  ///
  /// [code] is the access code to validate
  /// [isEntry] indicates whether this is an entry code (true) or exit code (false)
  ///
  /// Returns true if the code is valid, false otherwise
  Future<bool> validateAccessCode({
    required String code,
    required bool isEntry,
  });

  /// Checks if a user is in the gym
  ///
  /// [userId] is the unique identifier of the user
  ///
  /// Returns true if the user is in the gym, false otherwise
  Future<bool> isUserInGym({required String userId});

  /// Gets the user ID associated with an access code
  ///
  /// [code] is the access code to lookup
  ///
  /// Returns the userId if found, null otherwise
  Future<String?> getUserIdFromCode(String code);
}
