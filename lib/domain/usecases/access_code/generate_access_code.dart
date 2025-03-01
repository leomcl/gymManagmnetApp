import 'package:test/domain/repositories/access_code_repository.dart';

class GenerateAccessCode {
  final AccessCodeRepository repository;

  GenerateAccessCode(this.repository);

  Future<String> call({
    required String userId,
    required bool isEntry,
  }) async {
    return await repository.generateAccessCode(
      userId: userId,
      isEntry: isEntry,
    );
  }
} 