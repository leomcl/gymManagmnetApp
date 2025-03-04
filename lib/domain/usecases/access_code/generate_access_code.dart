import 'package:test/domain/repositories/access_code_repository.dart';
import 'package:test/domain/repositories/auth_repository.dart';

class GenerateAccessCode {
  final AccessCodeRepository accessCodeRepository;
  final AuthRepository authRepository;

  GenerateAccessCode(this.accessCodeRepository, this.authRepository);

  Future<String?> call({
    required String userId,
    required bool isEntry,
  }) async {
    // Check user membership status before generating code
    final user = await authRepository.getUserById(userId);
    if (user == null || !user.membershipStatus) {
      throw Exception('Active membership required to generate access code');
    }

    // Don't allow entry if user is already in the gym
    if (isEntry) {
      final isInGym = await accessCodeRepository.isUserInGym(userId: userId);
      if (isInGym) {
        throw Exception('User is already in the gym');
      }
    } else {
      // Don't allow exit if user is not in the gym
      final isInGym = await accessCodeRepository.isUserInGym(userId: userId);
      if (!isInGym) {
        throw Exception('Cannot generate exit code: User is not in the gym');
      }
    }

    // Add dynamic expiry time based on business rules
    Duration expiry;
    if (isEntry) {
      expiry = const Duration(minutes: 15); // Short expiry for entry
    } else {
      expiry = const Duration(hours: 1); // Longer expiry for exit
    }

    // Now generate the code with the repository
    return await accessCodeRepository.generateAccessCode(
      userId: userId,
      isEntry: isEntry,
      expiry: expiry,
    );
  }
} 