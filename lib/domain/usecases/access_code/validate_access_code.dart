import 'package:test/domain/repositories/access_code_repository.dart';

class ValidateAccessCode {
  final AccessCodeRepository repository;

  ValidateAccessCode(this.repository);

  Future<bool> call({
    required String code,
    required bool isEntry,
  }) async {
    return await repository.validateAccessCode(
      code: code,
      isEntry: isEntry,
    );
  }
} 