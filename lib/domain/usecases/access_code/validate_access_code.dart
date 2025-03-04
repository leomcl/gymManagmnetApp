import 'package:test/domain/repositories/access_code_repository.dart';

class ValidateAccessCode {
  final AccessCodeRepository repository;

  ValidateAccessCode(this.repository);

  Future<bool> call({
    required String code,
    required bool isEntry,
  }) async {
    // Basic validation of code format
    if (code.length != 6 || int.tryParse(code) == null) {
      return false;
    }

    // Add business logic: Exit codes must be for users already in the gym
    if (!isEntry) {
      // Get the userId from the code document
      final userId = await repository.getUserIdFromCode(code);
      if (userId == null) {
        return false;
      }

      // Verify the user is actually in the gym before allowing exit
      final isInGym = await repository.isUserInGym(userId: userId);
      if (!isInGym) {
        return false; // Prevent exit if not in gym
      }
    }

    // If all business rules pass, validate the code itself
    return await repository.validateAccessCode(
      code: code,
      isEntry: isEntry,
    );
  }
}
