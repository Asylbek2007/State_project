import '../repositories/admin_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for deleting a user.
class DeleteUserUseCase {
  final AdminRepository repository;

  const DeleteUserUseCase(this.repository);

  /// Execute - delete a user by fullName.
  /// 
  /// Throws [ValidationFailure] if fullName is empty.
  /// Throws [SheetsFailure] if Google Sheets operation fails.
  Future<void> call(String fullName) async {
    if (fullName.trim().isEmpty) {
      throw const ValidationFailure('Имя не может быть пустым');
    }

    await repository.deleteUser(fullName.trim());
  }
}

