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
} 